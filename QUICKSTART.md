# Quick Start Guide

**Get Wazuh SIEM Enhancement deployed in 30 minutes**

---

## ⚡ Prerequisites Check (2 minutes)

### Verify Required Software

```bash
# Check Wazuh Manager is running
sudo systemctl status wazuh-manager

# Check Elasticsearch is accessible
curl -X GET "localhost:9200/_cluster/health?pretty"

# Check Grafana is running
sudo systemctl status grafana-server
```

### Requirements Checklist

- ✅ **Wazuh Manager 4.3+** (tested on 4.7.0)
- ✅ **Elasticsearch 7.10+** (bundled with Wazuh)
- ✅ **Grafana 10.0+** (tested on 12.2.0)
- ✅ **Ubuntu 22.04 LTS** (or compatible Linux)
- ✅ **Root/sudo access** to Wazuh manager
- ✅ **At least one Windows agent** configured with Sysmon

**If any component is missing, install Wazuh first:** https://documentation.wazuh.com/current/installation-guide/

---

## 🚀 Installation Overview

This installation includes **three core components:**

1. **Detection Rules** (26 custom rules) - 5 minutes
2. **D3FEND Enrichment Pipeline** (398 technique mappings) - 10 minutes  
3. **Grafana Dashboard** (60+ panels) - 10 minutes

**Total Time:** ~30 minutes (first-time setup)

---

## 📦 Step 1: Clone Repository (1 minute)

```bash
cd /tmp
git clone https://github.com/bajraroshan/wazuh-siem-enhancement.git
cd wazuh-siem-enhancement
```

**Verify download:**
```bash
ls -l
# You should see:
# - rules/
# - dashboards/
# - d3fend/
# - scripts/
# - README.md
```

---

## 🎯 Step 2: Deploy Detection Rules (5 minutes)

### Backup Existing Configuration

```bash
# Create backup directory
sudo mkdir -p /var/ossec/backup

# Backup current rules (if they exist)
sudo cp /var/ossec/etc/rules/local_rules.xml \
   /var/ossec/backup/local_rules.xml.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
```

### Deploy Custom Rules

```bash
# Copy rules to Wazuh
sudo cp rules/local_rules.xml /var/ossec/etc/rules/

# Set correct permissions
sudo chown wazuh:wazuh /var/ossec/etc/rules/local_rules.xml
sudo chmod 640 /var/ossec/etc/rules/local_rules.xml
```

### Verify Rules Loaded

```bash
# Test rule syntax
sudo /var/ossec/bin/wazuh-logtest -t

# You should see output like:
# Total rules enabled: 26
# (+ baseline Wazuh rules)
```

### Restart Wazuh Manager

```bash
sudo systemctl restart wazuh-manager

# Wait 10 seconds for restart
sleep 10

# Verify service is running
sudo systemctl status wazuh-manager
```

**✅ Checkpoint 1:** 26 detection rules deployed successfully

---

## 🛡️ Step 3: Install D3FEND Enrichment Pipeline (10 minutes)

This pipeline automatically enriches alerts with MITRE D3FEND countermeasure recommendations.

### Run Automated Installer

```bash
cd d3fend

# Make script executable
chmod +x install-d3fend-pipeline.sh

# Run installer (requires sudo)
sudo bash install-d3fend-pipeline.sh
```

**The script will:**
1. Check Elasticsearch connectivity
2. Create ingest pipeline with enrichment logic
3. Import 398 ATT&CK → D3FEND mappings
4. Update Wazuh index template
5. Verify installation

### Expected Output

```
[INFO] Checking Elasticsearch connectivity...
[OK] Elasticsearch is accessible

[INFO] Creating D3FEND enrichment pipeline...
[OK] Pipeline created: d3fend-enrichment

[INFO] Importing ATT&CK → D3FEND mappings...
[OK] Imported 398 technique mappings (1,247 countermeasures)

[INFO] Updating index template...
[OK] Template updated: wazuh-alerts

[INFO] Verifying installation...
[OK] D3FEND enrichment pipeline is active

[SUCCESS] Installation complete!
```

### Manual Verification

```bash
# Check pipeline exists
curl -X GET "localhost:9200/_ingest/pipeline/d3fend-enrichment?pretty"

# You should see JSON output with pipeline definition
```

**✅ Checkpoint 2:** D3FEND enrichment pipeline installed and active

---

## 📊 Step 4: Import Grafana Dashboard (10 minutes)

### Access Grafana Web Interface

1. Open browser: `http://your-server:3000`
2. Login (default credentials: `admin` / `admin`)
3. Change password when prompted (or skip)

### Configure Elasticsearch Datasource

**If you already have Wazuh datasource configured, skip to "Import Dashboard"**

1. Click **Configuration** (⚙️ icon) → **Data sources**
2. Click **Add data source**
3. Search and select **Elasticsearch**
4. Configure settings:

```
Name: Wazuh-Alerts
URL: http://localhost:9200
Access: Server (default)

Index settings:
  Index name: wazuh-alerts-*
  Pattern: Daily
  Time field name: timestamp

Elasticsearch details:
  Version: 7.10+ (select your version)
  Max concurrent Shard Requests: 5
```

5. Scroll to bottom → Click **Save & Test**
6. You should see: ✅ **"Data source is working"**

**Troubleshooting datasource:**
```bash
# If connection fails, verify Elasticsearch is accessible
curl -X GET "localhost:9200"

# Check index exists
curl -X GET "localhost:9200/_cat/indices/wazuh-alerts-*?v"
```

### Import Dashboard

1. Click **Dashboards** (📊 icon) → **Import**
2. Click **Upload JSON file**
3. Navigate to: `/tmp/wazuh-siem-enhancement/dashboards/`
4. Select: `wazuh-mitre-advanced-threat-dashboard.json`
5. Configure import:
   - **Name:** Wazuh MITRE ATT&CK Advanced Threat Analysis
   - **Folder:** Wazuh Dashboards (create if needed)
   - **Select datasource:** Choose "Wazuh-Alerts"
6. Click **Import**

**Dashboard should load with 6 sections:**
- Section 1: MITRE ATT&CK Overview
- Section 2: LOLBins Detection
- Section 3: Fileless Malware Indicators
- Section 4: APT Campaign Analytics  
- Section 5: D3FEND Countermeasure Guidance
- Section 6: System Health

**✅ Checkpoint 3:** Dashboard imported successfully

---

## 🧪 Step 5: Generate Test Alerts (5 minutes)

### Test Detection Rules

Run the systematic test suite to validate installation:

```powershell
# On a Windows machine with Wazuh agent installed
# Open PowerShell as Administrator

# Navigate to test script
cd C:\path\to\wazuh-siem-enhancement\scripts

# Run test suite
.\Run-SystematicTests.ps1

# Expected output:
# [Test 1.1] PowerShell -enc (short flag) - ✓ PASS
# [Test 1.2] PowerShell -EncodedCommand (full flag) - ✓ PASS
# [Test 2.1] CertUtil download simulation - ✓ PASS
# ...
# [Results] 33/35 tests passed (94.3%)
```

### Quick Manual Test (Alternative)

If you can't run PowerShell tests, use wazuh-logtest:

```bash
# On Wazuh manager
# Test PowerShell encoded command detection
echo '{"win":{"eventdata":{"commandLine":"powershell.exe -enc VwByAGkAdABlAC0ASABvAHMAdAAgACIAVABlAHMAdAAiAA=="}}}' | \
  sudo /var/ossec/bin/wazuh-logtest -U 100500:1

# Expected output:
# **Phase 1: Completed pre-decoding.
# **Phase 2: Completed decoding.
# **Rule debugging:
#    Rule id: '100500'
#    Level: '12'
#    Description: 'PowerShell: Encoded Command Execution'
```

### Verify Alerts in Dashboard

1. Go back to Grafana dashboard
2. Set time range to **Last 15 minutes** (top-right corner)
3. Click **Refresh** (🔄 icon)
4. You should see test alerts appear in:
   - "Total Alerts" panel
   - "LOLBins Detection" section
   - "Alert Timeline" panel
5. Click on an alert to see **D3FEND countermeasures** displayed

**✅ Checkpoint 4:** Test alerts generated and visible in dashboard

---

## ✅ Final Verification Checklist

### Detection Rules
- [ ] 26 custom rules are loaded (check with `wazuh-logtest -t`)
- [ ] Wazuh manager is running (no errors in `/var/ossec/logs/ossec.log`)
- [ ] Test alert triggers successfully
- [ ] Rules have MITRE ATT&CK tags (check rule XML)

### D3FEND Enrichment
- [ ] Pipeline exists (`curl localhost:9200/_ingest/pipeline/d3fend-enrichment`)
- [ ] 398 technique mappings loaded
- [ ] Test alerts show `d3fend.countermeasures` fields
- [ ] No enrichment errors in Elasticsearch logs

### Grafana Dashboard
- [ ] All 6 sections load without errors
- [ ] Elasticsearch datasource connected (green checkmark)
- [ ] Panels display data (or "No data" if no alerts yet)
- [ ] D3FEND guidance panels show countermeasures
- [ ] No red error messages in browser console (F12)

### System Health
- [ ] Wazuh manager: `Active (running)`
- [ ] Elasticsearch cluster: `green` or `yellow` status
- [ ] Grafana: Accessible and responsive
- [ ] Dashboard query time: <5 seconds
- [ ] No performance degradation

**If all checkboxes are ✅, installation is complete!**

---

## 🎯 What You've Deployed

### Detection Capabilities

| Component | Details |
|-----------|---------|
| **Detection Rules** | 26 custom rules |
| **MITRE ATT&CK Coverage** | 10 techniques, 6 tactics |
| **Detection Rate** | 92.9% (vs. 7.1% baseline) |
| **False Positive Rate** | 0% in validation testing |

### D3FEND Integration

| Component | Details |
|-----------|---------|
| **Technique Mappings** | 398 ATT&CK techniques (78%) |
| **Countermeasures** | 1,247 defensive actions |
| **Enrichment Success** | 100% (in testing) |
| **Enrichment Latency** | 42ms average |

### Visualization

| Component | Details |
|-----------|---------|
| **Dashboard Panels** | 60+ visual elements |
| **Dashboard Sections** | 6 major categories |
| **Query Performance** | 2.1s (10K alerts) |
| **Load Time** | 2.8s (initial) |

---

## 🚀 Next Steps

### Immediate Actions (First Hour)

**1. Explore the Dashboard**

Navigate through each section:
- **Overview:** Get high-level statistics
- **LOLBins Detection:** See which binaries are being abused
- **Fileless Indicators:** Track memory-resident threats
- **APT Analytics:** View risk-scored hosts
- **D3FEND Guidance:** Learn defensive countermeasures
- **System Health:** Monitor performance

**2. Configure Auto-Refresh**

- Click time range selector (top-right)
- Set auto-refresh: **30 seconds** (recommended)
- For active incidents, use **10 seconds**

**3. Bookmark Dashboard**

- Click ⭐ icon (top-right) to add to favorites
- Share URL with SOC team

### First Day Activities

**1. Generate Normal Traffic**

- Perform typical user activities on monitored endpoints
- Document what triggers alerts (legitimate vs. suspicious)
- Identify false positives (if any)

**2. Review Alert Details**

For each alert, check:
- Which rule triggered?
- What MITRE ATT&CK technique?
- What D3FEND countermeasures are suggested?
- Is this expected behavior?

**3. Test Specific Techniques**

Use the validation suite to see how each technique appears:

```powershell
# Run specific test category
.\Run-SystematicTests.ps1 -Category PowerShell
.\Run-SystematicTests.ps1 -Category CertUtil
.\Run-SystematicTests.ps1 -Category WMIC
```

### First Week Goals

**1. Establish Baselines**

- Monitor for 7 days continuously
- Document normal alert volume
- Identify peak activity times
- Note legitimate tool usage patterns

**2. Tune Detection Rules (if needed)**

If you find false positives:

```bash
# Edit rules
sudo nano /var/ossec/etc/rules/local_rules.xml

# Add exceptions or adjust severity
# Example: Add regex exclusion for approved scripts

# Restart Wazuh
sudo systemctl restart wazuh-manager
```

**3. Create Response Procedures**

For each alert type, document:
- What does this alert mean?
- How urgent is it?
- What should we check?
- Who should be notified?
- What actions should we take?

**4. Train Your Team**

- Schedule 30-minute walkthrough
- Show how to navigate dashboard
- Demonstrate alert investigation workflow
- Practice using D3FEND guidance

### First Month Objectives

**1. Measure Performance**

Track these metrics:
- Total alerts per day
- High-severity alerts per week
- Mean time to detection (MTTD)
- Mean time to response (MTTR)
- False positive rate

**2. Expand Coverage**

Consider:
- Additional Windows detection rules
- Linux agent deployment (if applicable)
- Network-based detection
- Application-specific rules

**3. Integration**

Connect with existing tools:
- Ticketing system (JIRA, ServiceNow)
- Email notifications
- Slack/Teams alerts
- SOAR platform (if available)

**4. Contribute Back**

Found a bug? Improved a rule? Created new detection?
- Open GitHub issue: https://github.com/bajraroshan/wazuh-siem-enhancement/issues
- Submit pull request with improvements
- Share learnings in Discussions

---

## 🔧 Common Issues & Solutions

### Issue 1: Dashboard Shows "No Data"

**Symptoms:**
- All panels show "No data"
- Time range is set correctly
- Elasticsearch datasource is green

**Solution:**
```bash
# Step 1: Verify alerts exist in Elasticsearch
curl -X GET "localhost:9200/wazuh-alerts-*/_count?pretty"
# Should return: "count" : <some number>

# Step 2: Check index pattern in datasource
# Grafana → Configuration → Data Sources → Wazuh-Alerts
# Verify: Index name = wazuh-alerts-*

# Step 3: Generate a test alert
cd /tmp/wazuh-siem-enhancement/scripts
# Run test suite on Windows agent

# Step 4: Refresh dashboard
# Wait 30 seconds, then click Refresh button
```

---

### Issue 2: D3FEND Countermeasures Not Appearing

**Symptoms:**
- Alerts appear in dashboard
- But D3FEND guidance section is empty
- No countermeasure recommendations

**Solution:**
```bash
# Step 1: Verify pipeline is active
curl -X GET "localhost:9200/_ingest/pipeline/d3fend-enrichment?pretty"

# Step 2: Check if alerts are being enriched
curl -X GET "localhost:9200/wazuh-alerts-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 1,
  "query": { "match_all": {} },
  "_source": ["rule.mitre.id", "d3fend.countermeasures"]
}'

# Should show d3fend fields in response

# Step 3: If enrichment is missing, reinstall pipeline
cd /tmp/wazuh-siem-enhancement/d3fend
sudo bash install-d3fend-pipeline.sh --force
```

---

### Issue 3: Rules Not Triggering

**Symptoms:**
- Detection rules are loaded
- But no alerts are generated
- Even for known malicious activity

**Solution:**
```bash
# Step 1: Verify Wazuh is receiving logs
sudo tail -f /var/ossec/logs/ossec.log
# Look for: "Analyzing event" messages

# Step 2: Check if Windows agent is sending Sysmon logs
# On Windows endpoint with agent:
# Event Viewer → Applications and Services Logs → Microsoft → Windows → Sysmon/Operational
# Generate test event (e.g., run certutil)

# Step 3: Test rule logic directly
sudo /var/ossec/bin/wazuh-logtest
# Paste sample Sysmon event
# Should show which rule matched

# Step 4: Check rule syntax
sudo /var/ossec/bin/wazuh-logtest -t
# Look for any errors in custom rules

# Step 5: Verify agent is active
# Wazuh Dashboard → Agents
# Check agent status and last keep-alive
```

---

### Issue 4: Wazuh Manager Won't Restart

**Symptoms:**
- After copying rules, Wazuh won't start
- Error in logs about rule configuration

**Solution:**
```bash
# Step 1: Check logs for specific error
sudo tail -50 /var/ossec/logs/ossec.log
# Look for: "ERROR" or "CRITICAL"

# Step 2: Test configuration syntax
sudo /var/ossec/bin/wazuh-logtest -t
# Will show line number of any XML errors

# Step 3: Common issues:
# - Missing closing tag (</rule>)
# - Invalid PCRE2 regex
# - Duplicate rule IDs
# - Wrong file permissions

# Step 4: Restore backup if needed
sudo cp /var/ossec/backup/local_rules.xml.backup.* \
   /var/ossec/etc/rules/local_rules.xml

# Step 5: Fix the error and try again
sudo systemctl start wazuh-manager
```

---

### Issue 5: High CPU Usage After Installation

**Symptoms:**
- Elasticsearch CPU spikes to 100%
- Dashboard is slow to load
- Queries take >10 seconds

**Solution:**
```bash
# Step 1: Check Elasticsearch heap size
curl -X GET "localhost:9200/_nodes/stats/jvm?pretty"
# heap_used_percent should be <85%

# Step 2: Increase heap if needed (max 50% of RAM)
sudo nano /etc/elasticsearch/jvm.options
# Adjust: -Xms4g and -Xmx4g (example for 8GB RAM)

# Step 3: Optimize dashboard queries
# Grafana → Dashboard Settings → Variables
# Reduce time range: 24 hours instead of 7 days

# Step 4: Consider index optimization
curl -X POST "localhost:9200/wazuh-alerts-*/_forcemerge?max_num_segments=1&pretty"
# Note: This is resource-intensive, run during maintenance window

# Step 5: Check disk I/O
iostat -x 1 10
# If await >50ms, consider faster storage
```

---

### Issue 6: Test Suite Fails on Windows

**Symptoms:**
- PowerShell script won't run
- "Execution policy" error
- Tests don't complete

**Solution:**
```powershell
# Step 1: Check execution policy
Get-ExecutionPolicy

# Step 2: Allow script execution (as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Step 3: Unblock script if downloaded from internet
Unblock-File -Path ".\Run-SystematicTests.ps1"

# Step 4: Run with bypass flag
powershell.exe -ExecutionPolicy Bypass -File .\Run-SystematicTests.ps1

# Step 5: If API queries fail, check Elasticsearch connectivity
# From Windows machine:
Test-NetConnection -ComputerName <wazuh-server-ip> -Port 9200
```

---

## 💡 Pro Tips

### Tip 1: Create Custom Views

Filter dashboard for specific scenarios:

**High-Risk Hosts Only:**
- Variables → Risk Threshold → Set to "High"
- Shows only hosts with risk score >7

**Specific Technique:**
- Variables → MITRE Technique → Select "T1059.001"
- Shows only PowerShell-related alerts

**Time Window:**
- Time range → Custom → Last 4 hours
- Useful for incident investigation

### Tip 2: Export Data for Reporting

Create management reports:

```bash
# Export last 7 days of high-severity alerts
curl -X GET "localhost:9200/wazuh-alerts-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 1000,
  "query": {
    "bool": {
      "must": [
        { "range": { "rule.level": { "gte": 10 } } },
        { "range": { "timestamp": { "gte": "now-7d" } } }
      ]
    }
  }
}' > high_severity_alerts.json

# Convert to CSV using jq (install if needed)
cat high_severity_alerts.json | jq -r '.hits.hits[]._source | 
  [.timestamp, .agent.name, .rule.description, .rule.level] | @csv' > alerts.csv
```

### Tip 3: Set Up Alert Notifications

Configure Grafana to send notifications:

1. **Grafana → Alerting → Contact points**
2. **Add contact point:**
   - Name: "SOC Team"
   - Type: Email / Slack / Teams
   - Configure recipient details
3. **Create alert rule:**
   - Panel → Edit → Alert tab
   - Condition: Count > 10 (adjust as needed)
   - Evaluation interval: 1 minute
   - Notification: SOC Team

### Tip 4: Regular Maintenance Schedule

```bash
# Weekly: Backup Wazuh configuration
# Add to crontab: 0 3 * * 0
sudo tar -czf /var/ossec/backup/wazuh-config-$(date +%Y%m%d).tar.gz \
  /var/ossec/etc/rules/local_rules.xml \
  /var/ossec/etc/ossec.conf

# Monthly: Optimize Elasticsearch indices
# Add to crontab: 0 2 1 * *
curl -X POST "localhost:9200/wazuh-alerts-*/_forcemerge?max_num_segments=1"

# Monthly: Review and clean old alerts (>90 days)
# Add to crontab: 0 4 1 * *
curator_cli --host localhost --port 9200 delete_indices \
  --filter_list '[{"filtertype":"age","source":"name","direction":"older",
  "timestring":"%Y.%m.%d","unit":"days","unit_count":90}]'
```

### Tip 5: Benchmark Your Improvements

Track before/after metrics:

**Before Enhancement:**
- Detection rate: 7.1% (baseline Wazuh)
- MTTR: Unknown (no visualization)
- Manual queries: 15-25 minutes per investigation

**After Enhancement (measure at 30 days):**
- Detection rate: Target 92.9%
- MTTR: Target <10 minutes
- Manual queries: Eliminated (dashboard-based)

Document your improvements:
- Create GitHub issue with your metrics
- Share with community
- Contribute to success stories

---

## 📚 Additional Resources

### Documentation
- **README.md** - Project overview and quick start
- **PROJECT_STRUCTURE.md** - Complete file organization
- **GitHub Repository** - https://github.com/bajraroshan/wazuh-siem-enhancement

### External Resources
- **Wazuh Documentation** - https://documentation.wazuh.com/
- **MITRE ATT&CK** - https://attack.mitre.org/
- **MITRE D3FEND** - https://d3fend.mitre.org/
- **Grafana Documentation** - https://grafana.com/docs/
- **LOLBAS Project** - https://lolbas-project.github.io/

### Community Support
- **GitHub Issues** - Report bugs, request features
- **GitHub Discussions** - Ask questions, share experiences
- **Wazuh Community** - https://groups.google.com/g/wazuh

---

## 🆘 Getting Help

### Before Asking for Help

1. **Check the error logs:**
   ```bash
   # Wazuh
   sudo tail -100 /var/ossec/logs/ossec.log
   
   # Elasticsearch
   sudo tail -100 /var/log/elasticsearch/elasticsearch.log
   
   # Grafana
   sudo tail -100 /var/log/grafana/grafana.log
   ```

2. **Search existing issues:**
   - https://github.com/bajraroshan/wazuh-siem-enhancement/issues
   - Include your error message in search

3. **Check compatibility:**
   - Wazuh version ≥ 4.3
   - Elasticsearch version ≥ 7.10
   - Grafana version ≥ 10.0

### How to Report Issues

When creating a GitHub issue, include:

**1. Environment Details:**
```
Wazuh Manager: [version]
Elasticsearch: [version]
Grafana: [version]
OS: [Ubuntu 22.04 / etc.]
```

**2. What You Did:**
```
Step 1: Ran install-d3fend-pipeline.sh
Step 2: Restarted Wazuh
Step 3: Imported dashboard
```

**3. What Happened:**
```
Dashboard shows "No data"
Browser console error: [paste error]
```

**4. What You Expected:**
```
Dashboard should display alerts
```

**5. Relevant Logs:**
```bash
[Paste relevant log sections]
```

### Response Time Expectations

- **Community Support:** 24-48 hours (volunteers)
- **Bug Reports:** 1-7 days (depending on severity)
- **Feature Requests:** Best effort (community-driven)

---

## 🎉 Success!

**You've successfully deployed Wazuh SIEM Enhancement!**

### What You've Achieved

✅ **Enhanced Detection:** 92.9% detection rate (vs. 7.1% baseline)  
✅ **Automated Enrichment:** 398 techniques mapped to D3FEND countermeasures  
✅ **Visual Analytics:** 60+ dashboard panels for threat analysis  
✅ **Validated System:** 94.3% test suite pass rate  

### Join the Community

⭐ **Star the repository:** https://github.com/bajraroshan/wazuh-siem-enhancement  
💬 **Join discussions:** Share your deployment experience  
🐛 **Report issues:** Help improve the project  
🤝 **Contribute:** Submit pull requests with improvements  

---

## 📊 Deployment Summary

| Component | Status | Time |
|-----------|--------|------|
| Prerequisites | ✅ Complete | 2 min |
| Detection Rules | ✅ Complete | 5 min |
| D3FEND Enrichment | ✅ Complete | 10 min |
| Grafana Dashboard | ✅ Complete | 10 min |
| Test Validation | ✅ Complete | 5 min |
| **Total** | **✅ Deployed** | **~32 min** |

---

## 📞 Quick Reference

**Wazuh Manager:**
```bash
sudo systemctl status wazuh-manager    # Check status
sudo systemctl restart wazuh-manager   # Restart service
sudo tail -f /var/ossec/logs/ossec.log # View logs
```

**Elasticsearch:**
```bash
curl localhost:9200/_cluster/health?pretty  # Check health
curl localhost:9200/_cat/indices/wazuh-*   # List indices
```

**Grafana:**
```bash
sudo systemctl status grafana-server        # Check status
http://your-server:3000                     # Access UI
```

---

**🎊 Congratulations on your deployment!**

**Questions?** → [GitHub Discussions](https://github.com/bajraroshan/wazuh-siem-enhancement/discussions)

**Found a bug?** → [Report Issue](https://github.com/bajraroshan/wazuh-siem-enhancement/issues/new)

**Made improvements?** → [Submit Pull Request](https://github.com/bajraroshan/wazuh-siem-enhancement/pulls)