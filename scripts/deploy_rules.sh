#!/bin/bash
#
# Wazuh SIEM Enhancement - Automated Deployment Script
# Deploys custom detection rules to Wazuh manager
#
# Usage: sudo ./deploy_rules.sh [options]
# Options:
#   --dry-run    : Show what would be done without making changes
#   --no-backup  : Skip backup creation (not recommended)
#   --no-restart : Don't restart Wazuh manager after deployment
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WAZUH_DIR="/var/ossec"
RULES_DIR="$WAZUH_DIR/etc/rules"
CONFIG_FILE="$WAZUH_DIR/etc/ossec.conf"
RULES_FILE="custom_detection_rules.xml"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE_RULES="$PROJECT_DIR/rules/$RULES_FILE"

# Flags
DRY_RUN=false
NO_BACKUP=false
NO_RESTART=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-backup)
            NO_BACKUP=true
            shift
            ;;
        --no-restart)
            NO_RESTART=true
            shift
            ;;
        -h|--help)
            echo "Usage: sudo $0 [options]"
            echo "Options:"
            echo "  --dry-run     Show what would be done without making changes"
            echo "  --no-backup   Skip backup creation (not recommended)"
            echo "  --no-restart  Don't restart Wazuh manager after deployment"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Function to print colored messages
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

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        echo "Please run: sudo $0"
        exit 1
    fi
}

# Function to check if Wazuh is installed
check_wazuh_installed() {
    if [[ ! -d "$WAZUH_DIR" ]]; then
        print_error "Wazuh installation not found at $WAZUH_DIR"
        exit 1
    fi
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Wazuh configuration file not found at $CONFIG_FILE"
        exit 1
    fi
    
    print_success "Wazuh installation verified"
}

# Function to check Wazuh version
check_wazuh_version() {
    local version_output=$($WAZUH_DIR/bin/wazuh-control info | grep "WAZUH_VERSION" | cut -d'"' -f2)
    local version=$(echo "$version_output" | cut -d'v' -f2)
    local major=$(echo "$version" | cut -d'.' -f1)
    local minor=$(echo "$version" | cut -d'.' -f2)
    
    print_info "Detected Wazuh version: v$version"
    
    if [[ $major -lt 4 ]] || [[ $major -eq 4 && $minor -lt 8 ]]; then
        print_warning "Wazuh version 4.8+ recommended for full MITRE ATT&CK support"
        print_warning "Current version: v$version"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Wazuh version compatible"
    fi
}

# Function to validate source rules file
validate_source_rules() {
    if [[ ! -f "$SOURCE_RULES" ]]; then
        print_error "Source rules file not found: $SOURCE_RULES"
        exit 1
    fi
    
    print_info "Validating source rules file..."
    
    # Check XML syntax
    if command -v xmllint &> /dev/null; then
        if ! xmllint --noout "$SOURCE_RULES" 2>/dev/null; then
            print_error "Invalid XML syntax in rules file"
            exit 1
        fi
        print_success "XML syntax valid"
    else
        print_warning "xmllint not found, skipping XML validation"
    fi
    
    # Count rules
    local rule_count=$(grep -c '<rule id=' "$SOURCE_RULES" || true)
    print_info "Found $rule_count rules in source file"
}

# Function to create backup
create_backup() {
    if [[ "$NO_BACKUP" == true ]]; then
        print_warning "Skipping backup creation (--no-backup flag)"
        return
    fi
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$RULES_DIR/backup_$timestamp"
    
    print_info "Creating backup at $backup_dir..."
    
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$backup_dir"
        
        # Backup existing custom rules if present
        if [[ -f "$RULES_DIR/$RULES_FILE" ]]; then
            cp "$RULES_DIR/$RULES_FILE" "$backup_dir/"
            print_success "Backed up existing $RULES_FILE"
        fi
        
        # Backup local_rules.xml
        if [[ -f "$RULES_DIR/local_rules.xml" ]]; then
            cp "$RULES_DIR/local_rules.xml" "$backup_dir/"
            print_success "Backed up local_rules.xml"
        fi
        
        # Backup ossec.conf
        cp "$CONFIG_FILE" "$backup_dir/"
        print_success "Backed up ossec.conf"
        
        echo "$timestamp" > "$backup_dir/backup_info.txt"
        print_success "Backup created successfully"
        echo "Backup location: $backup_dir"
    else
        print_info "[DRY RUN] Would create backup at $backup_dir"
    fi
}

# Function to deploy rules file
deploy_rules() {
    print_info "Deploying custom detection rules..."
    
    local dest_file="$RULES_DIR/$RULES_FILE"
    
    if [[ "$DRY_RUN" == false ]]; then
        # Copy rules file
        cp "$SOURCE_RULES" "$dest_file"
        
        # Set ownership
        chown wazuh:wazuh "$dest_file"
        
        # Set permissions
        chmod 640 "$dest_file"
        
        print_success "Rules deployed to $dest_file"
        
        # Verify file
        if [[ -f "$dest_file" ]]; then
            local size=$(du -h "$dest_file" | cut -f1)
            print_info "File size: $size"
        fi
    else
        print_info "[DRY RUN] Would copy $SOURCE_RULES to $dest_file"
        print_info "[DRY RUN] Would set ownership to wazuh:wazuh"
        print_info "[DRY RUN] Would set permissions to 640"
    fi
}

# Function to update ossec.conf
update_config() {
    print_info "Checking ossec.conf configuration..."
    
    # Check if custom rules are already included
    if grep -q "custom_detection_rules.xml" "$CONFIG_FILE"; then
        print_success "Custom rules already included in configuration"
        return
    fi
    
    print_info "Adding custom rules include to ossec.conf..."
    
    if [[ "$DRY_RUN" == false ]]; then
        # Create temporary file with the addition
        local temp_file=$(mktemp)
        
        # Add include before </ruleset>
        sed '/<\/ruleset>/i\  <include>custom_detection_rules.xml<\/include>' "$CONFIG_FILE" > "$temp_file"
        
        # Replace original file
        mv "$temp_file" "$CONFIG_FILE"
        
        # Restore ownership and permissions
        chown root:wazuh "$CONFIG_FILE"
        chmod 640 "$CONFIG_FILE"
        
        print_success "Configuration updated"
    else
        print_info "[DRY RUN] Would add <include>custom_detection_rules.xml</include> to ossec.conf"
    fi
}

# Function to validate Wazuh configuration
validate_wazuh_config() {
    print_info "Validating Wazuh configuration..."
    
    if [[ "$DRY_RUN" == false ]]; then
        if $WAZUH_DIR/bin/wazuh-logtest -t 2>&1 | grep -q "Total rules enabled"; then
            local rule_count=$($WAZUH_DIR/bin/wazuh-logtest -t 2>&1 | grep "Total rules enabled" | grep -oP '\d+')
            print_success "Configuration valid. Total rules: $rule_count"
        else
            print_error "Configuration validation failed"
            print_info "Check logs: tail -f $WAZUH_DIR/logs/ossec.log"
            exit 1
        fi
    else
        print_info "[DRY RUN] Would validate configuration with wazuh-logtest"
    fi
}

# Function to restart Wazuh manager
restart_wazuh() {
    if [[ "$NO_RESTART" == true ]]; then
        print_warning "Skipping Wazuh restart (--no-restart flag)"
        print_info "Remember to restart manually: systemctl restart wazuh-manager"
        return
    fi
    
    print_info "Restarting Wazuh manager..."
    
    if [[ "$DRY_RUN" == false ]]; then
        systemctl restart wazuh-manager
        
        # Wait for service to start
        sleep 3
        
        # Check status
        if systemctl is-active --quiet wazuh-manager; then
            print_success "Wazuh manager restarted successfully"
        else
            print_error "Wazuh manager failed to start"
            print_info "Check status: systemctl status wazuh-manager"
            print_info "Check logs: tail -f $WAZUH_DIR/logs/ossec.log"
            exit 1
        fi
    else
        print_info "[DRY RUN] Would restart wazuh-manager service"
    fi
}

# Function to verify deployment
verify_deployment() {
    print_info "Verifying deployment..."
    
    if [[ "$DRY_RUN" == false ]]; then
        # Check if rules file exists
        if [[ ! -f "$RULES_DIR/$RULES_FILE" ]]; then
            print_error "Rules file not found after deployment"
            exit 1
        fi
        
        # Check file permissions
        local perms=$(stat -c "%a" "$RULES_DIR/$RULES_FILE")
        if [[ "$perms" != "640" ]]; then
            print_warning "Unexpected file permissions: $perms (expected: 640)"
        fi
        
        # Check ownership
        local owner=$(stat -c "%U:%G" "$RULES_DIR/$RULES_FILE")
        if [[ "$owner" != "wazuh:wazuh" ]]; then
            print_warning "Unexpected file ownership: $owner (expected: wazuh:wazuh)"
        fi
        
        # Count deployed rules
        local deployed_rules=$(grep -c '<rule id=' "$RULES_DIR/$RULES_FILE" || true)
        print_info "Deployed rules count: $deployed_rules"
        
        print_success "Deployment verified"
    else
        print_info "[DRY RUN] Would verify deployment"
    fi
}

# Function to print next steps
print_next_steps() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║            DEPLOYMENT COMPLETED SUCCESSFULLY               ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo ""
    echo "1. Import Grafana Dashboard:"
    echo "   - Access Grafana at http://your-server:3000"
    echo "   - Navigate to: Dashboards → Import"
    echo "   - Upload: $PROJECT_DIR/dashboards/wazuh-mitre-attack-advanced-threat-analysis.json"
    echo ""
    echo "2. Generate Test Alerts:"
    echo "   - Review test cases: $PROJECT_DIR/test_cases/"
    echo "   - Execute techniques on monitored systems"
    echo "   - Verify alerts appear in dashboard"
    echo ""
    echo "3. Tune Detection Rules:"
    echo "   - Monitor for false positives"
    echo "   - Adjust severity levels as needed"
    echo "   - Add environment-specific exceptions"
    echo ""
    echo "4. Documentation:"
    echo "   - Installation guide: $PROJECT_DIR/docs/installation-guide.md"
    echo "   - User guide: $PROJECT_DIR/docs/dashboard-user-guide.md"
    echo ""
    echo -e "${YELLOW}Support:${NC}"
    echo "   - Issues: https://github.com/yourusername/wazuh-siem-enhancement/issues"
    echo "   - Discussions: https://github.com/yourusername/wazuh-siem-enhancement/discussions"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     Wazuh SIEM Enhancement - Deployment Script            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [[ "$DRY_RUN" == true ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    # Pre-flight checks
    print_info "Running pre-flight checks..."
    check_root
    check_wazuh_installed
    check_wazuh_version
    validate_source_rules
    echo ""
    
    # Deployment steps
    print_info "Beginning deployment..."
    echo ""
    
    create_backup
    echo ""
    
    deploy_rules
    echo ""
    
    update_config
    echo ""
    
    validate_wazuh_config
    echo ""
    
    restart_wazuh
    echo ""
    
    verify_deployment
    echo ""
    
    if [[ "$DRY_RUN" == false ]]; then
        print_next_steps
    else
        print_info "[DRY RUN] Deployment simulation completed"
        print_info "Run without --dry-run to perform actual deployment"
    fi
}

# Run main function
main