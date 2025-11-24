#!/bin/bash

################################################################################
# Wazuh SIEM Enhancement - D3FEND Enrichment Pipeline Installer
# 
# This script installs the automated MITRE D3FEND enrichment pipeline
# that adds countermeasure recommendations to Wazuh alerts in real-time.
#
# Author: Roshan Bajracharya
# Repository: https://github.com/bajraroshan/wazuh-siem-enhancement
# License: GPL v3.0
################################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ELASTICSEARCH_HOST="${ELASTICSEARCH_HOST:-localhost}"
ELASTICSEARCH_PORT="${ELASTICSEARCH_PORT:-9200}"
PIPELINE_NAME="d3fend-enrichment"
INDEX_PATTERN="wazuh-alerts-*"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║   Wazuh SIEM Enhancement - D3FEND Enrichment Installer       ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

################################################################################
# Prerequisite Checks
################################################################################

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root or with sudo"
        exit 1
    fi
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        print_error "curl is not installed. Install it with: sudo apt-get install curl"
        exit 1
    fi
    
    # Check if jq is installed (for JSON processing)
    if ! command -v jq &> /dev/null; then
        print_warning "jq is not installed. Installing..."
        apt-get update -qq && apt-get install -y jq &> /dev/null
        if [ $? -eq 0 ]; then
            print_success "jq installed successfully"
        else
            print_error "Failed to install jq. Install manually: sudo apt-get install jq"
            exit 1
        fi
    fi
    
    print_success "Prerequisites check passed"
}

################################################################################
# Elasticsearch Connectivity Check
################################################################################

check_elasticsearch() {
    print_info "Checking Elasticsearch connectivity..."
    
    # Try to connect to Elasticsearch
    ES_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}" 2>/dev/null)
    
    if [ "$ES_RESPONSE" != "200" ]; then
        print_error "Cannot connect to Elasticsearch at ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}"
        print_error "HTTP Status Code: ${ES_RESPONSE}"
        print_info "Please check:"
        echo "  1. Elasticsearch is running: sudo systemctl status elasticsearch"
        echo "  2. Port ${ELASTICSEARCH_PORT} is accessible"
        echo "  3. Firewall allows connections"
        exit 1
    fi
    
    # Get Elasticsearch version
    ES_VERSION=$(curl -s "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}" | jq -r '.version.number')
    print_success "Elasticsearch is accessible (version: ${ES_VERSION})"
    
    # Check cluster health
    CLUSTER_HEALTH=$(curl -s "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_cluster/health" | jq -r '.status')
    print_info "Elasticsearch cluster health: ${CLUSTER_HEALTH}"
    
    if [ "$CLUSTER_HEALTH" == "red" ]; then
        print_warning "Cluster health is RED. Installation will continue, but investigate issues."
    fi
}

################################################################################
# Create D3FEND Enrichment Pipeline
################################################################################

create_enrichment_pipeline() {
    print_info "Creating D3FEND enrichment pipeline..."
    
    # Check if pipeline JSON file exists
    if [ ! -f "${SCRIPT_DIR}/d3fend-enrichment-pipeline.json" ]; then
        print_error "Pipeline file not found: ${SCRIPT_DIR}/d3fend-enrichment-pipeline.json"
        exit 1
    fi
    
    # Check if pipeline already exists
    PIPELINE_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
        "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_ingest/pipeline/${PIPELINE_NAME}" 2>/dev/null)
    
    if [ "$PIPELINE_EXISTS" == "200" ]; then
        print_warning "Pipeline '${PIPELINE_NAME}' already exists"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping pipeline creation"
            return 0
        fi
        print_info "Overwriting existing pipeline..."
    fi
    
    # Create the pipeline
    RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
        "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_ingest/pipeline/${PIPELINE_NAME}" \
        -H 'Content-Type: application/json' \
        -d @"${SCRIPT_DIR}/d3fend-enrichment-pipeline.json")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" == "200" ]; then
        print_success "Pipeline '${PIPELINE_NAME}' created successfully"
    else
        print_error "Failed to create pipeline. HTTP Status: ${HTTP_CODE}"
        echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
        exit 1
    fi
}

################################################################################
# Load D3FEND Mappings
################################################################################

load_d3fend_mappings() {
    print_info "Loading ATT&CK → D3FEND mappings..."
    
    # Check if mapping file exists
    if [ ! -f "${SCRIPT_DIR}/mitre-to-d3fend-mapping-398.json" ]; then
        print_error "Mapping file not found: ${SCRIPT_DIR}/mitre-to-d3fend-mapping-398.json"
        exit 1
    fi
    
    # Validate JSON file
    if ! jq empty "${SCRIPT_DIR}/mitre-to-d3fend-mapping-398.json" 2>/dev/null; then
        print_error "Invalid JSON in mapping file"
        exit 1
    fi
    
    # Count techniques in mapping file
    TECHNIQUE_COUNT=$(jq 'keys | length' "${SCRIPT_DIR}/mitre-to-d3fend-mapping-398.json")
    print_info "Found ${TECHNIQUE_COUNT} technique mappings in file"
    
    # Create a dedicated index for D3FEND mappings (if it doesn't exist)
    INDEX_NAME="wazuh-d3fend-mappings"
    
    # Check if index exists
    INDEX_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
        "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${INDEX_NAME}" 2>/dev/null)
    
    if [ "$INDEX_EXISTS" == "200" ]; then
        print_warning "Index '${INDEX_NAME}' already exists"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Deleting existing index..."
            curl -s -X DELETE "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${INDEX_NAME}" > /dev/null
            print_success "Index deleted"
        else
            print_info "Keeping existing mappings"
            return 0
        fi
    fi
    
    # Create index with proper mapping
    print_info "Creating index for D3FEND mappings..."
    
    curl -s -X PUT "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${INDEX_NAME}" \
        -H 'Content-Type: application/json' \
        -d '{
          "mappings": {
            "properties": {
              "technique_id": { "type": "keyword" },
              "technique_name": { "type": "text" },
              "countermeasures": {
                "properties": {
                  "actions": { "type": "keyword" },
                  "descriptions": { "type": "text" },
                  "implementations": { "type": "text" },
                  "priority": { "type": "keyword" }
                }
              },
              "parent_technique": { "type": "keyword" },
              "tactic": { "type": "keyword" }
            }
          }
        }' > /dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Index created"
    else
        print_error "Failed to create index"
        exit 1
    fi
    
    # Bulk import mappings
    print_info "Importing mappings (this may take 30-60 seconds)..."
    
    # Convert JSON to bulk format and import
    jq -r 'to_entries[] | 
        "{\"index\":{\"_index\":\"'"${INDEX_NAME}"'\"}}\n" + 
        "{\"technique_id\":\"\(.key)\",\"countermeasures\":\(.value)}"' \
        "${SCRIPT_DIR}/mitre-to-d3fend-mapping-398.json" | \
    curl -s -X POST "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_bulk" \
        -H 'Content-Type: application/x-ndjson' \
        --data-binary @- > /dev/null
    
    if [ $? -eq 0 ]; then
        # Refresh index to make documents searchable
        curl -s -X POST "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${INDEX_NAME}/_refresh" > /dev/null
        
        # Verify import
        IMPORTED_COUNT=$(curl -s "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${INDEX_NAME}/_count" | jq -r '.count')
        print_success "Imported ${IMPORTED_COUNT} technique mappings"
        
        if [ "$IMPORTED_COUNT" != "$TECHNIQUE_COUNT" ]; then
            print_warning "Imported count (${IMPORTED_COUNT}) doesn't match file count (${TECHNIQUE_COUNT})"
        fi
    else
        print_error "Failed to import mappings"
        exit 1
    fi
}

################################################################################
# Update Wazuh Index Template
################################################################################

update_index_template() {
    print_info "Updating Wazuh index template to use enrichment pipeline..."
    
    # Get current template
    TEMPLATE_NAME="wazuh-alerts"
    TEMPLATE_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
        "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_index_template/${TEMPLATE_NAME}" 2>/dev/null)
    
    if [ "$TEMPLATE_EXISTS" != "200" ]; then
        # Try legacy template API
        TEMPLATE_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
            "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_template/${TEMPLATE_NAME}" 2>/dev/null)
        
        if [ "$TEMPLATE_EXISTS" != "200" ]; then
            print_error "Wazuh template not found. Ensure Wazuh is properly installed."
            exit 1
        fi
        
        USE_LEGACY_API=true
    else
        USE_LEGACY_API=false
    fi
    
    # Get current template
    if [ "$USE_LEGACY_API" = true ]; then
        CURRENT_TEMPLATE=$(curl -s "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_template/${TEMPLATE_NAME}")
    else
        CURRENT_TEMPLATE=$(curl -s "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_index_template/${TEMPLATE_NAME}")
    fi
    
    # Add pipeline to template settings
    if [ "$USE_LEGACY_API" = true ]; then
        # Legacy template API
        UPDATED_TEMPLATE=$(echo "$CURRENT_TEMPLATE" | jq \
            --arg pipeline "$PIPELINE_NAME" \
            '.[].settings."index.default_pipeline" = $pipeline')
        
        RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
            "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_template/${TEMPLATE_NAME}" \
            -H 'Content-Type: application/json' \
            -d "$UPDATED_TEMPLATE")
    else
        # New index template API
        UPDATED_TEMPLATE=$(echo "$CURRENT_TEMPLATE" | jq \
            --arg pipeline "$PIPELINE_NAME" \
            '.index_templates[0].index_template.template.settings."index.default_pipeline" = $pipeline')
        
        RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
            "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_index_template/${TEMPLATE_NAME}" \
            -H 'Content-Type: application/json' \
            -d "$UPDATED_TEMPLATE")
    fi
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    
    if [ "$HTTP_CODE" == "200" ]; then
        print_success "Index template updated successfully"
        print_info "New alerts will be automatically enriched with D3FEND guidance"
    else
        print_warning "Failed to update template automatically (HTTP: ${HTTP_CODE})"
        print_info "You can manually update the template or apply pipeline per-index"
        print_info "Manual command:"
        echo "  curl -X PUT \"http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${INDEX_PATTERN}/_settings\" \\"
        echo "    -H 'Content-Type: application/json' \\"
        echo "    -d '{\"index.default_pipeline\": \"${PIPELINE_NAME}\"}'"
    fi
}

################################################################################
# Apply Pipeline to Existing Indices
################################################################################

apply_to_existing_indices() {
    print_info "Applying pipeline to existing indices..."
    
    read -p "Do you want to apply enrichment to existing Wazuh indices? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping existing indices (only new alerts will be enriched)"
        return 0
    fi
    
    # Get list of Wazuh indices
    INDICES=$(curl -s "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_cat/indices/wazuh-alerts-*?h=index" | sort)
    
    if [ -z "$INDICES" ]; then
        print_warning "No existing wazuh-alerts indices found"
        return 0
    fi
    
    INDEX_COUNT=$(echo "$INDICES" | wc -l)
    print_info "Found ${INDEX_COUNT} existing indices"
    
    # Apply pipeline to each index
    for index in $INDICES; do
        print_info "Updating index: ${index}"
        
        RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
            "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${index}/_settings" \
            -H 'Content-Type: application/json' \
            -d "{\"index.default_pipeline\": \"${PIPELINE_NAME}\"}")
        
        HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
        
        if [ "$HTTP_CODE" == "200" ]; then
            echo "  ✓ Updated"
        else
            echo "  ✗ Failed (HTTP: ${HTTP_CODE})"
        fi
    done
    
    print_success "Pipeline applied to existing indices"
    print_warning "Note: Only NEW documents will be enriched. Existing documents remain unchanged."
    print_info "To reindex existing documents with enrichment, see documentation"
}

################################################################################
# Verification
################################################################################

verify_installation() {
    print_info "Verifying installation..."
    
    ERRORS=0
    
    # Check 1: Pipeline exists
    echo -n "  Checking pipeline existence... "
    PIPELINE_CHECK=$(curl -s -o /dev/null -w "%{http_code}" \
        "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_ingest/pipeline/${PIPELINE_NAME}")
    
    if [ "$PIPELINE_CHECK" == "200" ]; then
        echo "✓"
    else
        echo "✗"
        ((ERRORS++))
    fi
    
    # Check 2: Mappings index exists
    echo -n "  Checking D3FEND mappings index... "
    MAPPINGS_CHECK=$(curl -s -o /dev/null -w "%{http_code}" \
        "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/wazuh-d3fend-mappings")
    
    if [ "$MAPPINGS_CHECK" == "200" ]; then
        echo "✓"
    else
        echo "✗"
        ((ERRORS++))
    fi
    
    # Check 3: Mappings count
    echo -n "  Checking mapping count... "
    MAPPING_COUNT=$(curl -s "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/wazuh-d3fend-mappings/_count" | jq -r '.count')
    
    if [ "$MAPPING_COUNT" -gt 300 ]; then
        echo "✓ (${MAPPING_COUNT} mappings)"
    else
        echo "✗ (only ${MAPPING_COUNT} mappings)"
        ((ERRORS++))
    fi
    
    # Check 4: Test enrichment with sample document
    echo -n "  Testing enrichment with sample alert... "
    
    TEST_DOC='{
      "rule": {
        "mitre": {
          "id": ["T1059.001"]
        }
      }
    }'
    
    TEST_RESULT=$(echo "$TEST_DOC" | \
        curl -s -X POST "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_ingest/pipeline/${PIPELINE_NAME}/_simulate" \
        -H 'Content-Type: application/json' \
        -d @-)
    
    ENRICHED=$(echo "$TEST_RESULT" | jq -r '.docs[0].doc._source.d3fend.countermeasures.actions[0]' 2>/dev/null)
    
    if [ -n "$ENRICHED" ] && [ "$ENRICHED" != "null" ]; then
        echo "✓"
        print_info "    Sample enrichment: ${ENRICHED}"
    else
        echo "✗"
        ((ERRORS++))
    fi
    
    echo ""
    
    if [ $ERRORS -eq 0 ]; then
        print_success "All verification checks passed!"
    else
        print_warning "Some verification checks failed (${ERRORS} errors)"
        print_info "Installation may be incomplete. Check logs above."
    fi
}

################################################################################
# Summary and Next Steps
################################################################################

print_summary() {
    echo ""
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Installation Complete!                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo "D3FEND Enrichment Pipeline has been successfully installed."
    echo ""
    echo "Components Installed:"
    echo "  ✓ Enrichment pipeline: ${PIPELINE_NAME}"
    echo "  ✓ Mapping database: wazuh-d3fend-mappings"
    echo "  ✓ Technique coverage: 398 ATT&CK techniques"
    echo "  ✓ Countermeasures: 1,247 defensive actions"
    echo ""
    echo "What happens now:"
    echo "  • New Wazuh alerts will be automatically enriched"
    echo "  • D3FEND countermeasures added to each alert"
    echo "  • Five new fields per alert:"
    echo "    - d3fend.countermeasures.actions"
    echo "    - d3fend.countermeasures.descriptions"
    echo "    - d3fend.countermeasures.implementations"
    echo "    - d3fend.countermeasures.priority"
    echo "    - d3fend.mapping_type"
    echo ""
    echo "Next Steps:"
    echo "  1. Import Grafana dashboard to view D3FEND guidance"
    echo "  2. Generate test alert to verify enrichment"
    echo "  3. Check dashboard D3FEND section for countermeasures"
    echo ""
    echo "Testing:"
    echo "  # Generate test alert on Windows agent"
    echo "  powershell.exe -enc VwByAGkAdABlAC0ASABvAHMAdAAgACIAVABlAHMAdAAiAA=="
    echo ""
    echo "  # Verify enrichment in Elasticsearch"
    echo "  curl \"http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/wazuh-alerts-*/_search?pretty\" \\"
    echo "    -H 'Content-Type: application/json' \\"
    echo "    -d '{\"size\":1,\"query\":{\"match_all\":{}},\"_source\":[\"d3fend\"]}'"
    echo ""
    echo "Documentation:"
    echo "  https://github.com/bajraroshan/wazuh-siem-enhancement"
    echo ""
}

################################################################################
# Cleanup on Error
################################################################################

cleanup_on_error() {
    print_error "Installation failed. Cleaning up..."
    
    # Optionally remove created resources
    # (Commented out to preserve partial installation for troubleshooting)
    # curl -s -X DELETE "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_ingest/pipeline/${PIPELINE_NAME}" > /dev/null
    # curl -s -X DELETE "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/wazuh-d3fend-mappings" > /dev/null
    
    print_info "Partial installation preserved for troubleshooting"
    exit 1
}

################################################################################
# Main Installation Flow
################################################################################

main() {
    # Set error trap
    trap cleanup_on_error ERR
    
    # Print header
    print_header
    
    # Run installation steps
    check_prerequisites
    echo ""
    
    check_elasticsearch
    echo ""
    
    create_enrichment_pipeline
    echo ""
    
    load_d3fend_mappings
    echo ""
    
    update_index_template
    echo ""
    
    apply_to_existing_indices
    echo ""
    
    verify_installation
    echo ""
    
    print_summary
}

################################################################################
# Script Entry Point
################################################################################

# Check for help flag
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    echo "Wazuh SIEM Enhancement - D3FEND Enrichment Installer"
    echo ""
    echo "Usage: sudo bash install-d3fend-pipeline.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  ELASTICSEARCH_HOST  Elasticsearch hostname (default: localhost)"
    echo "  ELASTICSEARCH_PORT  Elasticsearch port (default: 9200)"
    echo ""
    echo "Example:"
    echo "  sudo bash install-d3fend-pipeline.sh"
    echo "  ELASTICSEARCH_HOST=es-server sudo bash install-d3fend-pipeline.sh"
    echo ""
    exit 0
fi

# Run main installation
main

exit 0
