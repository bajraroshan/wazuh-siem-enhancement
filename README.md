# Wazuh SIEM Enhancement: Automated D3FEND Enrichment

Enhanced threat detection platform for Wazuh SIEM with automated MITRE D3FEND countermeasure integration, delivering commercial-grade security operations capabilities at zero licensing cost.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Wazuh](https://img.shields.io/badge/Wazuh-4.7.0+-blue)](https://wazuh.com/)
[![MITRE ATT&CK](https://img.shields.io/badge/MITRE-ATT%26CK%20v14-red)](https://attack.mitre.org/)
[![D3FEND](https://img.shields.io/badge/MITRE-D3FEND-green)](https://d3fend.mitre.org/)

---

## 🎯 Project Overview

This capstone project extends the open-source Wazuh SIEM platform with:

- **26 Custom Detection Rules** targeting Living-off-the-Land binaries (LOLBins), fileless malware, and evasive techniques
- **Advanced Grafana Dashboard** with 60+ panels providing unified threat visualization and attack chain analysis
- **Automated D3FEND Enrichment Pipeline** injecting real-time countermeasure guidance into alerts
- **398 ATT&CK Technique Coverage** with automated D3FEND defensive recommendations
- **Systematic Validation Suite** with 35 adversary-simulation test cases
- **100% MITRE ATT&CK Integration** across all detection rules

### Key Achievements

| Metric | Baseline Wazuh | Enhanced System | Improvement |
|--------|---------------|-----------------|-------------|
| Detection Rate | 7.1% | 92.9% | **+85.8 pp** |
| True Positives | 5/70 | 65/70 | **13× increase** |
| D3FEND Enrichment | 0% | 100% | **Full coverage** |
| Statistical Significance | - | χ²=42.9, p<0.001 | **Significant** |

---

## 💡 Problem Statement

Commercial SIEM platforms cost **$200,000-$500,000 annually**, placing advanced threat detection beyond reach of resource-constrained organizations. Open-source alternatives like Wazuh provide basic monitoring but lack:

- ❌ Detection coverage for evasive techniques (LOLBins, fileless malware)
- ❌ Real-time defensive countermeasure recommendations
- ❌ Consolidated threat visualization reducing analyst cognitive load
- ❌ Automated behavioral analytics for APT campaign identification

**This project bridges that gap** through systematic detection rule development, automated D3FEND enrichment, and advanced visualization.

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    WAZUH AGENTS (Endpoints)                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Windows  │  │  Linux   │  │  macOS   │  │  Server  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        └─────────────┴─────────────┴─────────────┘
                           │
                           ▼
        ┌────────────────────────────────────────┐
        │      WAZUH MANAGER (Detection)         │
        │  • 26 Custom Detection Rules           │
        │  • MITRE ATT&CK Mapping (10 Techniques)│
        │  • Alert Generation & Enrichment       │
        └──────────────┬─────────────────────────┘
                       │
                       ▼
        ┌────────────────────────────────────────┐
        │    ELASTICSEARCH (Indexing Layer)      │
        │  • D3FEND Enrichment Pipeline          │
        │  • 398 ATT&CK → D3FEND Mappings        │
        │  • Real-time Countermeasure Injection  │
        │  • Alert Storage & Querying            │
        └──────────────┬─────────────────────────┘
                       │
                       ▼
        ┌────────────────────────────────────────┐
        │      GRAFANA (Visualization Layer)     │
        │  • Advanced Threat Dashboard (60 Panels)│
        │  • Automated Risk Scoring              │
        │  • Attack Chain Timeline               │
        │  • D3FEND Guidance Display             │
        └────────────────────────────────────────┘
```

---

## 📦 Repository Contents

```
wazuh-siem-enhancement/
├── README.md                          # This file
├── LICENSE                            # GNU GPL v3.0
│
├── rules/                             # Detection Rules
│   └── local_rules.xml                # 26 custom Wazuh rules
│
├── dashboards/                        # Grafana Dashboards
│   └── wazuh-mitre-advanced-threat-dashboard.json
│
├── d3fend/                            # D3FEND Enrichment
│   ├── d3fend-enrichment-pipeline.json       # Elasticsearch ingest pipeline
│   ├── mitre-to-d3fend-mapping-398.json      # ATT&CK → D3FEND mappings
│   └── install-d3fend-pipeline.sh            # Deployment script
│
├── scripts/                           # Validation & Testing
│   └── Run-SystematicTests.ps1        # 35-test validation suite (847 lines)
│
└── docs/                              # Documentation
    ├── installation-guide.md
    ├── dashboard-user-guide.md
    └── testing-methodology.md
```

---

## 🚀 Quick Start

### Prerequisites

- Wazuh Manager 4.3+ (tested on 4.7.0)
- Elasticsearch 7.10+ (bundled with Wazuh)
- Grafana 10.0+ (tested on 12.2.0)
- Ubuntu 22.04 LTS (or compatible Linux)
- Root/Administrator access

### Installation

#### 1. Deploy Custom Detection Rules

```bash
# Backup existing rules
sudo cp /var/ossec/etc/rules/local_rules.xml /var/ossec/etc/rules/local_rules.xml.backup

# Clone repository
git clone https://github.com/bajraroshan/wazuh-siem-enhancement.git
cd wazuh-siem-enhancement

# Deploy custom rules
sudo cp rules/local_rules.xml /var/ossec/etc/rules/
sudo chown wazuh:wazuh /var/ossec/etc/rules/local_rules.xml

# Restart Wazuh manager
sudo systemctl restart wazuh-manager
```

#### 2. Install D3FEND Enrichment Pipeline

```bash
# Run automated installer
cd d3fend
sudo bash install-d3fend-pipeline.sh

# This script will:
# - Create Elasticsearch ingest pipeline
# - Import 398 ATT&CK → D3FEND mappings
# - Configure index template
# - Verify installation
```

#### 3. Import Grafana Dashboard

```bash
# Access Grafana web interface (default: http://your-server:3000)
# 1. Login with admin credentials
# 2. Navigate to: Dashboards → Import → Upload JSON file
# 3. Select: dashboards/wazuh-mitre-advanced-threat-dashboard.json
# 4. Configure Elasticsearch datasource if not already set up
```

#### 4. Configure Elasticsearch Datasource (if needed)

```
Settings → Data Sources → Add Elasticsearch
- URL: http://localhost:9200
- Index name: wazuh-alerts-*
- Time field: timestamp
```

---

## 🎯 Detection Coverage

### MITRE ATT&CK Techniques (26 Rules, 10 Techniques)

| Technique ID | Technique Name | Target Binary | Rules |
|--------------|----------------|---------------|-------|
| T1059.001 | PowerShell Execution | PowerShell.exe | 7 |
| T1140 | Deobfuscate/Decode | PowerShell.exe | 3 |
| T1105 | Ingress Tool Transfer | CertUtil.exe | 3 |
| T1047 | Windows Management | WMIC.exe | 3 |
| T1218.011 | Signed Binary Proxy | Rundll32.exe | 2 |
| T1218.005 | Signed Binary Proxy | MSHTA.exe | 2 |
| T1218.010 | Signed Binary Proxy | Regsvr32.exe | 2 |
| T1197 | BITS Jobs | BITSAdmin.exe | 2 |
| T1127.001 | Trusted Developer | MSBuild.exe | 1 |
| T1204.002 | User Execution | Multiple | 1 |

**Tactic Coverage:** 6 tactics (Execution, Defense Evasion, Persistence, Lateral Movement, Command & Control, Credential Access)

---

## 📊 Dashboard Features

### Section 1: MITRE ATT&CK Overview (8 Panels)
- Tactic distribution heatmap
- Technique frequency analysis
- Temporal alert timeline
- Severity breakdown

### Section 2: LOLBins Detection (12 Panels)
- Per-binary detection counts (PowerShell, CertUtil, WMIC, Rundll32, etc.)
- Host-based LOLBin activity mapping
- Command-line sample viewer
- Technique correlation matrix

### Section 3: Fileless Malware Indicators (10 Panels)
- Encoded command detection
- Download cradle identification
- Obfuscation pattern tracking
- Memory-resident threat indicators

### Section 4: APT Campaign Analytics (15 Panels)
- **Automated Risk Scoring:** Multi-factor behavioral analysis
  - Alert volume (30% weight)
  - Average severity (20% weight)
  - Tactic diversity (25% weight)
  - Technique variety (25% weight)
- Multi-tactic host identification
- Lateral movement visualization (source → target graphs)
- Attack chain timeline (kill-chain progression)
- Dwell time analysis

### Section 5: D3FEND Countermeasure Guidance (8 Panels)
- Inline countermeasure recommendations per alert
- Priority-ranked defensive actions
- Implementation guidance links
- Tool/vendor suggestions

### Section 6: System Health (7 Panels)
- Alert volume tracking
- Agent status monitoring
- Query performance metrics
- Elasticsearch health indicators

---

## 🔬 D3FEND Enrichment Pipeline

### Overview

Automated Elasticsearch ingest pipeline that enriches every Wazuh alert with MITRE D3FEND countermeasure recommendations **before indexing**.

### Pipeline Features

- **398 ATT&CK Technique Coverage** (78% of ATT&CK v14)
- **1,247 Technique-Countermeasure Mappings**
- **Hierarchical Matching Logic:**
  1. Exact technique match (78% of mappings)
  2. Parent technique fallback (16% of mappings)
  3. Tactic-level fallback (6% of mappings)
- **Five Injected Fields per Alert:**
  - `d3fend.countermeasures.actions` - List of defensive techniques
  - `d3fend.countermeasures.descriptions` - Full text guidance
  - `d3fend.countermeasures.implementations` - Tool/vendor names
  - `d3fend.countermeasures.priority` - High/Medium/Low ranking
  - `d3fend.mapping_type` - exact/parent/tactic/fallback

### Performance

| Metric | Result |
|--------|--------|
| Enrichment Success Rate | 100% (249/249 alerts in 7-day test) |
| Average Enrichment Latency | 42 ms |
| Peak Enrichment Latency | 87 ms |
| Failed Enrichments | 0 |

### Example Enriched Alert

```json
{
  "rule": {
    "description": "PowerShell: Encoded Command Execution",
    "mitre": {
      "id": ["T1059.001", "T1140"],
      "tactic": ["Execution", "Defense Evasion"]
    }
  },
  "d3fend": {
    "countermeasures": {
      "actions": [
        "Process Spawn Analysis",
        "Script Execution Analysis",
        "System Call Filtering"
      ],
      "descriptions": [
        "Monitor and analyze process creation events...",
        "Analyze scripts before execution...",
        "Filter and block suspicious system calls..."
      ],
      "implementations": [
        "Sysmon, EDR platforms",
        "PowerShell Constrained Language Mode",
        "Windows Defender Application Control"
      ],
      "priority": "High"
    },
    "mapping_type": "exact"
  }
}
```

---

## ✅ Validation & Testing

### Systematic Test Suite

**File:** `scripts/Run-SystematicTests.ps1` (847 lines)

- **35 Test Cases** covering all 26 detection rules
- **Automated Execution:** Full suite runs in 12 minutes
- **Benign Command Simulation:** No actual malware required
- **API Verification:** Automated Elasticsearch query validation

### Test Categories

| Category | Technique | Tests | Rules Covered |
|----------|-----------|-------|---------------|
| PowerShell Encoded | T1059.001, T1140 | 7 | 10 |
| CertUtil Misuse | T1105 | 3 | 3 |
| WMIC Lateral Movement | T1047 | 3 | 3 |
| Rundll32 Proxy Execution | T1218.011 | 2 | 2 |
| MSHTA Execution | T1218.005 | 2 | 2 |
| Regsvr32 Proxy | T1218.010 | 2 | 2 |
| BITSAdmin File Transfer | T1197 | 2 | 2 |
| MSBuild Execution | T1127.001 | 1 | 1 |
| Download Cradles | T1059.001 | 4 | 1 |
| Correlation Chains | Multiple | 9 | - |

### Example Test Execution

```powershell
# Run full test suite
.\scripts\Run-SystematicTests.ps1

# Sample output:
[Test 1.1] PowerShell -enc (short flag)
Expected: Rule 100500
Result: ✓ PASS (Alert ID: 1234567890, Latency: 2.3s)

[Test 1.2] PowerShell -EncodedCommand (full flag)
Expected: Rule 100500
Result: ✓ PASS (Alert ID: 1234567891, Latency: 1.9s)
```

### Validation Results

| Metric | Baseline Wazuh | Enhanced System |
|--------|----------------|-----------------|
| Total Tests | 35 | 35 |
| Tests Passed | 5 (14.3%) | 33 (94.3%) |
| Tests Failed | 30 (85.7%) | 2 (5.7%) |
| Average Detection Latency | - | 3.1 seconds |
| False Positives | 0 | 0 |

**Note:** 2 failed tests are correlation rules requiring specific timing that wasn't met in isolated execution.

---

## 📈 Performance Benchmarks

### Dashboard Performance

| Metric | Value |
|--------|-------|
| Initial Dashboard Load Time | 2.8 seconds |
| Query Response (10K alerts) | 2.1 seconds |
| Query Response (50K alerts) | 4.7 seconds |
| Concurrent Users Tested | 5 |
| Peak Elasticsearch Heap | 62% |
| Average CPU Utilization | 18% |

### System Resource Utilization (7-Day Monitoring)

| Component | Average | Peak |
|-----------|---------|------|
| Wazuh CPU Usage | 12% | 28% |
| Wazuh Memory Usage | 2.1 GB | 2.8 GB |
| Elasticsearch CPU | 15% | 34% |
| Elasticsearch Heap | 52% | 62% |

### Operational Results

- **249 alerts** processed over 7 days
- **100% enrichment success** (zero failures)
- **10,000+ events/day** ingestion rate
- **4 high-risk hosts** identified via risk scoring

---

## 🎓 Use Cases

### 1. Small-to-Medium Enterprises (SMEs)
**Challenge:** Cannot afford $200K-$500K commercial SIEM  
**Solution:** Deploy complete threat detection + visualization at zero licensing cost  
**Benefit:** Commercial-grade capabilities without enterprise budget

### 2. Managed Security Service Providers (MSSPs)
**Challenge:** Need scalable SOC infrastructure for multiple clients  
**Solution:** Replicate dashboard for multi-tenant monitoring  
**Benefit:** Reduced operational overhead per client

### 3. Educational Institutions
**Challenge:** Limited security budgets, high attack surface  
**Solution:** Open-source platform with comprehensive detection  
**Benefit:** Hands-on learning environment for cybersecurity students

### 4. Security Researchers
**Challenge:** Need flexible platform for detection research  
**Solution:** Extensible rule framework with ATT&CK integration  
**Benefit:** Rapid prototyping of new detection logic

---

## 🔧 Configuration

### Custom Risk Scoring

Edit dashboard panel queries to adjust risk weights:

```sql
SELECT
  agent_name,
  COUNT(*) as alert_count,
  AVG(rule_level) as avg_severity,
  COUNT(DISTINCT rule_mitre_tactic) as tactic_diversity,
  COUNT(DISTINCT rule_mitre_id) as technique_variety,
  (COUNT(*) * 0.3 + AVG(rule_level) * 0.2 +
   COUNT(DISTINCT rule_mitre_tactic) * 2.5 +
   COUNT(DISTINCT rule_mitre_id) * 2.0) as risk_score
FROM wazuh-alerts
GROUP BY agent_name
ORDER BY risk_score DESC
LIMIT 20
```

### Adding Custom Detection Rules

```xml
<rule id="100XXX" level="10">
  <if_sid>PARENT_RULE_ID</if_sid>
  <field name="win.eventdata.commandLine" type="pcre2">
    (?i)your_detection_pattern
  </field>
  <description>Your detection description</description>
  <mitre>
    <id>T1XXX.XXX</id>
  </mitre>
  <group>attack.tactic_name,lolbin</group>
</rule>
```

---

## ⚠️ Limitations

### Current Limitations

1. **Baseline Period:** 7-day monitoring insufficient for accurate false-positive rate assessment (requires 30-60 days)
2. **Test Realism:** Validation suite uses benign command simulations, not actual malware
3. **Platform Coverage:** Windows-focused; limited Linux/macOS detection rules
4. **Scalability:** Tested to 50,000 alerts; enterprise-scale (1M+ alerts/day) unverified
5. **User Validation:** MTTR reduction claims require controlled SOC analyst user studies
6. **D3FEND Coverage:** 78% of ATT&CK v14; some sub-techniques use parent/tactic fallbacks

### Known Issues

- Correlation rules may miss distributed attack chains with extended timing intervals
- PCRE2 patterns need enhancement for Unicode obfuscation techniques
- Grafana auto-refresh at 10s causes Elasticsearch query load spikes (30s recommended)

---

## 🚧 Future Work

- [ ] **Extended Platform Support:** Linux (20+ rules) and macOS detection rules
- [ ] **Machine Learning Integration:** Elasticsearch ML for behavioral anomaly detection
- [ ] **SOAR Integration:** Automated playbooks with TheHive/Cortex
- [ ] **Enhanced D3FEND Coverage:** Expand to 95%+ of ATT&CK v15
- [ ] **Production Validation:** 90-day SOC deployments with user studies
- [ ] **Community Contributions:** Publish to Wazuh Ruleset Repository

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Ways to Contribute

- Additional detection rules for emerging threats
- Dashboard panel enhancements
- Performance optimization
- D3FEND mapping expansions
- Documentation improvements
- Translation/localization

### Contribution Process

1. Fork the repository
2. Create feature branch (`git checkout -b feature/detection-t1234`)
3. Commit changes (`git commit -m 'Add detection for technique T1234'`)
4. Push to branch (`git push origin feature/detection-t1234`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0** - see [LICENSE](LICENSE) file for details.

- ✅ Commercial use permitted
- ✅ Modification and distribution allowed
- ✅ Private use permitted
- ⚠️ Modifications must be disclosed
- ⚠️ Same license required for derivatives

---

## 🙏 Acknowledgments

- **Wazuh Team:** Foundation SIEM platform
- **MITRE Corporation:** ATT&CK and D3FEND frameworks
- **LOLBAS Project:** LOLBin documentation
- **Grafana Labs:** Visualization platform
- **Security Community:** Threat intelligence and detection methodologies

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/bajraroshan/wazuh-siem-enhancement/issues)
- **Discussions:** [GitHub Discussions](https://github.com/bajraroshan/wazuh-siem-enhancement/discussions)
- **Email:** a1941176@adelaide.edu.au

---

## 📊 Project Status

- **Current Version:** 1.0.0 (Thesis Release)
- **Status:** Production-Ready
- **Last Updated:** November 2024
- **Maintenance:** Active

---

## 🌟 Star History

⭐ **Star this repository if you find it useful!**

[![Star History Chart](https://api.star-history.com/svg?repos=bajraroshan/wazuh-siem-enhancement&type=Date)](https://star-history.com/#bajraroshan/wazuh-siem-enhancement&Date)

---

**Made with ❤️ for the cybersecurity community**

*Democratizing advanced threat detection capabilities*