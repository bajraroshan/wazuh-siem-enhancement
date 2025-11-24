# Project Structure

**Complete directory structure and file organization for the Wazuh SIEM Enhancement project.**

---

## 📊 Implementation Status Legend

| Symbol | Status | Description |
|--------|--------|-------------|
| ✅ | **Implemented** | Currently available and functional |
| 🚧 | **In Progress** | Under active development |
| 📋 | **Planned** | Roadmap for future implementation |
| 📚 | **Optional** | Nice-to-have, community contributions welcome |

---

## 📁 Current Project Structure (v1.0.0)

```
wazuh-siem-enhancement/
├── rules/                              ✅ IMPLEMENTED
│   └── local_rules.xml                 ✅ 26 custom detection rules
│
├── dashboards/                         ✅ IMPLEMENTED
│   └── wazuh-mitre-advanced-threat-dashboard.json  ✅ 60+ panels
│
├── d3fend/                             ✅ IMPLEMENTED
│   ├── d3fend-enrichment-pipeline.json          ✅ Elasticsearch ingest pipeline
│   ├── mitre-to-d3fend-mapping-398.json         ✅ 398 technique mappings
│   └── install-d3fend-pipeline.sh               ✅ Automated installer script
│
├── scripts/                            ✅ IMPLEMENTED
│   └── Run-SystematicTests.ps1         ✅ 35-test validation suite (847 lines)
│
├── docs/                               🚧 IN PROGRESS
│   ├── installation-guide.md           📋 Planned
│   ├── dashboard-user-guide.md         📋 Planned
│   └── testing-methodology.md          📋 Planned
│
├── README.md                           ✅ IMPLEMENTED
├── LICENSE                             ✅ IMPLEMENTED (GPL v3.0)
├── CONTRIBUTING.md                     📋 Planned
└── CHANGELOG.md                        📋 Planned
```

---

## 🔮 Complete Future Structure (Roadmap)

**This section shows the full project structure as it will evolve. Current status is indicated for each component.**

```
wazuh-siem-enhancement/
│
├── .github/                            📋 PLANNED - GitHub Automation
│   ├── workflows/                      
│   │   ├── validate.yml               📋 CI/CD validation pipeline
│   │   └── release.yml                📋 Release automation
│   ├── ISSUE_TEMPLATE/                
│   │   ├── bug_report.md              📋 Bug report template
│   │   ├── feature_request.md         📋 Feature request template
│   │   └── security_report.md         📋 Security vulnerability template
│   └── PULL_REQUEST_TEMPLATE.md       📋 PR template
│
├── rules/                              ✅ IMPLEMENTED (Core)
│   ├── local_rules.xml                ✅ All 26 custom rules (CURRENT)
│   ├── README.md                      📋 Rules documentation
│   └── RULE_DEVELOPMENT_GUIDE.md      📋 How to create new rules
│
├── dashboards/                         ✅ IMPLEMENTED (Core)
│   ├── wazuh-mitre-advanced-threat-dashboard.json  ✅ Main dashboard (CURRENT)
│   ├── dashboard-configuration-guide.md    📋 Setup instructions
│   ├── panel-descriptions.md               📋 Panel documentation
│   └── query-optimization-guide.md         📋 Performance tuning
│
├── d3fend/                             ✅ IMPLEMENTED (Core)
│   ├── d3fend-enrichment-pipeline.json     ✅ Elasticsearch pipeline (CURRENT)
│   ├── mitre-to-d3fend-mapping-398.json    ✅ ATT&CK mappings (CURRENT)
│   ├── install-d3fend-pipeline.sh          ✅ Deployment script (CURRENT)
│   └── README.md                           📋 D3FEND integration overview
│
├── scripts/                            ✅ IMPLEMENTED (Core)
│   ├── Run-SystematicTests.ps1        ✅ 35-test validation suite (CURRENT)
│   ├── deploy_rules.sh                📋 Automated rule deployment
│   ├── validate_rules.py              📋 Rule syntax validation
│   ├── check_rule_conflicts.py        📋 Duplicate ID checker
│   ├── validate_mitre_mapping.py      📋 ATT&CK mapping validator
│   ├── generate_rule_docs.py          📋 Auto-generate rule docs
│   ├── benchmark_queries.sh           📋 Performance testing
│   ├── export_dashboard.sh            📋 Dashboard backup
│   ├── bulk_test_rules.sh             📋 Batch rule testing
│   └── README.md                      📋 Script usage guide
│
├── docs/                               🚧 IN PROGRESS
│   ├── installation-guide.md          📋 Detailed installation steps
│   ├── dashboard-user-guide.md        📋 Analyst workflow guide
│   ├── detection-rule-methodology.md  📋 Rule development approach
│   ├── performance-benchmarks.md      📋 Query performance data
│   ├── mitre-attack-mapping.md        📋 Technique coverage matrix
│   ├── troubleshooting-guide.md       📋 Common issues & solutions
│   ├── upgrade-guide.md               📋 Version upgrade procedures
│   ├── api-reference.md               📋 Wazuh API integration
│   ├── architecture-overview.md       📋 System architecture
│   └── contributing/                  📋 Contribution guides
│       ├── rule-contribution.md
│       ├── dashboard-contribution.md
│       └── documentation-contribution.md
│
├── test_cases/                         📋 PLANNED - Extended Testing
│   ├── lolbin_test_logs.txt          📋 LOLBin test samples
│   ├── fileless_test_logs.txt        📋 Fileless attack samples
│   ├── apt_simulation_logs.txt       📋 APT campaign samples
│   ├── false_positive_tests.txt      📋 Negative test cases
│   ├── edge_case_tests.txt           📋 Edge case scenarios
│   ├── testing-methodology.md        📋 Test procedures
│   └── atomic_red_team_mapping.md    📋 ART test mappings
│
├── research/                           📚 OPTIONAL - Academic Materials
│   ├── literature-review.md           📚 Related work analysis
│   ├── methodology.md                 📚 Research methodology
│   ├── results-analysis.md            📚 Performance evaluation
│   ├── references.bib                 📚 Bibliography
│   ├── figures/                       📚 Diagrams and charts
│   └── presentations/                 📚 Conference materials
│
├── examples/                           📋 PLANNED - Usage Examples
│   ├── soc_workflows/                 📋 SOC analyst workflows
│   │   ├── initial_triage.md
│   │   ├── apt_investigation.md
│   │   └── threat_hunting.md
│   ├── integration_examples/          📋 Integration with other tools
│   │   ├── splunk_integration.md
│   │   ├── elastic_siem_integration.md
│   │   └── soar_integration.md
│   └── custom_rules/                  📋 Example custom rules
│       ├── example_lolbin_rule.xml
│       └── example_fileless_rule.xml
│
├── assets/                             📋 PLANNED - Media Assets
│   ├── images/                        📋 Screenshots, diagrams
│   │   ├── dashboard_overview.png
│   │   ├── architecture_diagram.png
│   │   └── alert_flow.png
│   ├── videos/                        📋 Demo videos
│   └── logos/                         📋 Project branding
│
├── tools/                              📚 OPTIONAL - Development Tools
│   ├── rule_generator/                📚 Rule generation helper
│   ├── dashboard_builder/             📚 Dashboard creation tool
│   └── test_data_generator/           📚 Generate test datasets
│
├── .gitignore                          📋 PLANNED
├── .editorconfig                       📚 OPTIONAL
├── LICENSE                             ✅ IMPLEMENTED (GPL v3.0)
├── README.md                           ✅ IMPLEMENTED
├── CONTRIBUTING.md                     📋 PLANNED
├── CHANGELOG.md                        📋 PLANNED
├── CODE_OF_CONDUCT.md                  📚 OPTIONAL
├── SECURITY.md                         📋 PLANNED
├── AUTHORS.md                          📚 OPTIONAL
└── CITATION.cff                        📚 OPTIONAL (for academic citation)
```

---

## 📦 What's Available Right Now (v1.0.0)

### ✅ Core Detection Rules

**File:** `rules/local_rules.xml`

- **26 custom detection rules** covering 10 MITRE ATT&CK techniques
- **100% ATT&CK metadata** integration
- **PCRE2-based** command-line pattern matching
- **Severity calibration** (levels 6-12)

**Coverage:**
- PowerShell Execution (T1059.001) - 7 rules
- Deobfuscate/Decode (T1140) - 3 rules
- Ingress Tool Transfer (T1105) - 3 rules
- Windows Management (T1047) - 3 rules
- Signed Binary Proxy Execution (T1218.x) - 6 rules
- BITS Jobs (T1197) - 2 rules
- Trusted Developer Utilities (T1127.001) - 1 rule
- User Execution (T1204.002) - 1 rule

---

### ✅ Advanced Threat Dashboard

**File:** `dashboards/wazuh-mitre-advanced-threat-dashboard.json`

- **60+ visualization panels** across 6 sections
- **MITRE ATT&CK Overview** - Tactic/technique distribution
- **LOLBins Detection** - Per-binary activity tracking
- **Fileless Indicators** - Encoded commands, obfuscation
- **APT Analytics** - Risk scoring, lateral movement
- **D3FEND Guidance** - Inline countermeasure recommendations
- **System Health** - Performance monitoring

**Performance:**
- Dashboard load: 2.8 seconds
- Query response (10K alerts): 2.1 seconds
- Query response (50K alerts): 4.7 seconds

---

### ✅ D3FEND Enrichment Pipeline

**Files:** 
- `d3fend/d3fend-enrichment-pipeline.json`
- `d3fend/mitre-to-d3fend-mapping-398.json`
- `d3fend/install-d3fend-pipeline.sh`

**Features:**
- **398 ATT&CK technique coverage** (78% of ATT&CK v14)
- **1,247 technique-countermeasure mappings**
- **Automated enrichment** before indexing
- **100% success rate** in operational testing (249/249 alerts)
- **42ms average latency**

**Injected Fields:**
- `d3fend.countermeasures.actions`
- `d3fend.countermeasures.descriptions`
- `d3fend.countermeasures.implementations`
- `d3fend.countermeasures.priority`
- `d3fend.mapping_type`

---

### ✅ Validation Test Suite

**File:** `scripts/Run-SystematicTests.ps1`

- **35 test cases** covering all 26 detection rules
- **847 lines** of PowerShell automation
- **12-minute** full suite execution time
- **Automated verification** via Elasticsearch API
- **94.3% detection rate** (33/35 tests passed)

**Test Categories:**
- PowerShell encoded commands (7 tests)
- CertUtil misuse (3 tests)
- WMIC lateral movement (3 tests)
- LOLBin execution (Rundll32, MSHTA, Regsvr32, MSBuild)
- Behavioral correlation (9 tests)

---

## 🚀 Quick Start (Current Implementation)

### Minimum Required Files for Deployment

```bash
wazuh-siem-enhancement/
├── rules/local_rules.xml                                    ← Install first
├── d3fend/d3fend-enrichment-pipeline.json                   ← Install second
├── d3fend/mitre-to-d3fend-mapping-398.json                  ← Install second
├── d3fend/install-d3fend-pipeline.sh                        ← Run this script
├── dashboards/wazuh-mitre-advanced-threat-dashboard.json    ← Import to Grafana
└── scripts/Run-SystematicTests.ps1                          ← Validate deployment
```

### Installation Steps (Using Current Files)

```bash
# 1. Clone repository
git clone https://github.com/bajraroshan/wazuh-siem-enhancement.git
cd wazuh-siem-enhancement

# 2. Deploy detection rules
sudo cp rules/local_rules.xml /var/ossec/etc/rules/
sudo chown wazuh:wazuh /var/ossec/etc/rules/local_rules.xml
sudo systemctl restart wazuh-manager

# 3. Install D3FEND enrichment pipeline
cd d3fend
sudo bash install-d3fend-pipeline.sh

# 4. Import Grafana dashboard
# - Access Grafana web UI: http://your-server:3000
# - Navigate: Dashboards → Import → Upload JSON
# - Select: dashboards/wazuh-mitre-advanced-threat-dashboard.json

# 5. Validate installation
cd ../scripts
powershell.exe -ExecutionPolicy Bypass -File Run-SystematicTests.ps1
```

---

## 📋 Development Roadmap

### Phase 1: Foundation (✅ COMPLETE)
- [x] 26 custom detection rules
- [x] Advanced Grafana dashboard (60+ panels)
- [x] D3FEND enrichment pipeline (398 techniques)
- [x] Systematic validation suite (35 tests)
- [x] GitHub repository setup
- [x] README documentation

### Phase 2: Documentation (🚧 IN PROGRESS)
- [ ] Comprehensive installation guide
- [ ] Dashboard user guide for SOC analysts
- [ ] Rule development methodology
- [ ] Troubleshooting guide
- [ ] Performance benchmarks document
- [ ] MITRE ATT&CK coverage matrix

### Phase 3: Extended Testing (📋 PLANNED - Q1 2026)
- [ ] Atomic Red Team integration
- [ ] False positive test suite
- [ ] Edge case validation
- [ ] Long-term FPR baseline (30-60 days)
- [ ] Performance stress testing (1M+ alerts/day)

### Phase 4: Automation & CI/CD (📋 PLANNED - Q2 2026)
- [ ] GitHub Actions workflow for validation
- [ ] Automated rule syntax checking
- [ ] Dashboard JSON validation
- [ ] Security scanning
- [ ] Automated release process

### Phase 5: Community Features (📋 PLANNED - Q3 2026)
- [ ] Contributing guidelines
- [ ] Issue templates (bug, feature, security)
- [ ] PR templates
- [ ] Code of conduct
- [ ] Security policy
- [ ] Changelog automation

### Phase 6: Extended Platform Support (📋 PLANNED - Q4 2026)
- [ ] Linux detection rules (20+ rules)
- [ ] macOS detection rules (15+ rules)
- [ ] Network-based detection
- [ ] Container security rules
- [ ] Cloud platform rules (AWS, Azure, GCP)

### Phase 7: Advanced Features (📚 OPTIONAL - 2027+)
- [ ] Machine learning-based anomaly detection
- [ ] SOAR integration (TheHive, Cortex)
- [ ] Automated response playbooks
- [ ] Threat hunting query templates
- [ ] Multi-tenant dashboard support

---

## 🔧 File Naming Conventions

### Current Implementation

| File Type | Current Naming | Example |
|-----------|----------------|---------|
| Detection Rules | `local_rules.xml` | `rules/local_rules.xml` |
| Dashboard | `wazuh-mitre-advanced-threat-dashboard.json` | Single main dashboard |
| D3FEND Pipeline | `d3fend-enrichment-pipeline.json` | Elasticsearch ingest config |
| D3FEND Mappings | `mitre-to-d3fend-mapping-398.json` | JSON mapping database |
| Test Suite | `Run-SystematicTests.ps1` | PowerShell validation script |

### Future Naming Standards

| File Type | Format | Example |
|-----------|--------|---------|
| Rules | `<category>_rules.xml` | `lolbins_rules.xml` |
| Documentation | `<topic>-<subtopic>.md` | `installation-guide.md` |
| Scripts | `<action>_<object>.<ext>` | `deploy_rules.sh` |
| Test Cases | `<category>_test_<type>.txt` | `lolbin_test_logs.txt` |

---

## 📊 Current Project Statistics

### Detection Capabilities
- **Detection Rules:** 26 custom rules
- **MITRE ATT&CK Techniques:** 10 techniques
- **MITRE ATT&CK Tactics:** 6 tactics
- **Detection Rate:** 92.9% (vs. 7.1% baseline)
- **Improvement:** +85.8 percentage points
- **Statistical Significance:** χ²=42.9, p<0.001

### Visualization & Analysis
- **Dashboard Panels:** 60+ visual elements
- **Dashboard Load Time:** 2.8 seconds
- **Query Performance (10K):** 2.1 seconds
- **Query Performance (50K):** 4.7 seconds
- **Risk Scoring:** Automated multi-factor analysis

### D3FEND Integration
- **Technique Coverage:** 398 ATT&CK techniques (78%)
- **Mappings:** 1,247 technique-countermeasure pairs
- **Enrichment Success:** 100% (249/249 alerts)
- **Enrichment Latency:** 42ms average
- **Unique D3FEND Techniques:** 86

### Testing & Validation
- **Test Cases:** 35 adversary simulations
- **Test Suite Lines:** 847 (PowerShell)
- **Execution Time:** 12 minutes (full suite)
- **Tests Passed:** 33/35 (94.3%)
- **False Positives:** 0

### Code & Documentation
- **Total Files:** 7 core files (current)
- **Lines of Code (Rules):** ~450 lines (XML)
- **Lines of Code (Scripts):** 847 lines (PowerShell)
- **Documentation Pages:** README + thesis documentation

---

## 🎯 Priority Files for Next Release (v1.1.0)

### High Priority (Required for Production)
1. ✅ `rules/local_rules.xml` - Already implemented
2. ✅ `dashboards/wazuh-mitre-advanced-threat-dashboard.json` - Already implemented
3. ✅ `d3fend/d3fend-enrichment-pipeline.json` - Already implemented
4. 📋 `docs/installation-guide.md` - **NEEDED**
5. 📋 `docs/dashboard-user-guide.md` - **NEEDED**
6. 📋 `CONTRIBUTING.md` - **NEEDED**
7. 📋 `CHANGELOG.md` - **NEEDED**

### Medium Priority (Improves Usability)
8. 📋 `docs/troubleshooting-guide.md`
9. 📋 `.gitignore`
10. 📋 `scripts/deploy_rules.sh` (bash version)
11. 📋 `test_cases/lolbin_test_logs.txt`
12. 📋 `CODE_OF_CONDUCT.md`

### Low Priority (Nice to Have)
13. 📋 `.github/workflows/validate.yml`
14. 📋 `examples/soc_workflows/initial_triage.md`
15. 📋 `assets/images/dashboard_overview.png`
16. 📋 `SECURITY.md`

---

## 🔍 What's Missing vs. Commercial SIEMs

### Currently Not Implemented (But Planned)
- ❌ Long-term false positive rate baselines (requires 30-60 days)
- ❌ Machine learning-based anomaly detection
- ❌ Automated incident response (SOAR integration)
- ❌ Linux/macOS detection rules
- ❌ Network-based detection
- ❌ Threat intelligence feed integration
- ❌ Multi-tenant dashboards
- ❌ Compliance reporting (PCI-DSS, HIPAA, etc.)
- ❌ User behavior analytics (UBA)
- ❌ Forensic timeline reconstruction

### Intentionally Out of Scope
- ❌ Commercial support contracts
- ❌ SLA guarantees
- ❌ Certified training programs
- ❌ Managed detection services
- ❌ Incident response retainer

---

## 🚦 Getting Started Guide

### For End Users (SOC Analysts)

**You need these files:**
1. `rules/local_rules.xml`
2. `d3fend/` (all 3 files)
3. `dashboards/wazuh-mitre-advanced-threat-dashboard.json`

**Installation:** See README.md Quick Start section

---

### For Contributors (Developers)

**Clone the repository:**
```bash
git clone https://github.com/bajraroshan/wazuh-siem-enhancement.git
cd wazuh-siem-enhancement
```

**Current structure:**
```bash
tree -L 2
# You'll see:
# ├── rules/
# ├── dashboards/
# ├── d3fend/
# ├── scripts/
# ├── docs/ (empty or minimal)
# └── README.md
```

**What you can contribute:**
- Additional detection rules (expand beyond 26)
- Dashboard panel improvements
- D3FEND mapping expansions (beyond 398)
- Documentation (installation, usage, troubleshooting)
- Test cases (expand beyond 35)
- Automation scripts (deployment, validation)

---

### For Researchers (Academic Use)

**Citation files:**
- Currently: Cite thesis/paper
- Planned: `CITATION.cff` for automated citation

**Research materials:**
- Thesis document (external)
- Performance benchmarks (in product document)
- Methodology (in thesis)

---

## 📞 Support & Contact

### For Current Implementation
- **GitHub Issues:** Bug reports, feature requests
- **GitHub Discussions:** Questions, community support
- **Email:** a1941176@adelaide.edu.au

### For Future Features
- Check roadmap above (Phase 1-7)
- Open feature request on GitHub
- Contribute via pull request

---

## 📝 Version History

### v1.0.0 (Current - November 2024)
**Status:** Production-Ready Thesis Release

**Includes:**
- ✅ 26 custom detection rules
- ✅ 60-panel Grafana dashboard
- ✅ D3FEND enrichment pipeline (398 techniques)
- ✅ Systematic validation suite (35 tests)
- ✅ README documentation
- ✅ GPL v3.0 license

**Known Limitations:**
- Documentation is minimal (README only)
- Test suite is PowerShell-based (Windows-only)
- No automated deployment scripts (manual installation)
- No CI/CD pipeline
- No community contribution guidelines

### v1.1.0 (Planned - Q1 2025)
**Target Features:**
- 📋 Comprehensive installation guide
- 📋 Dashboard user manual
- 📋 CONTRIBUTING.md
- 📋 CHANGELOG.md
- 📋 Bash deployment script
- 📋 Additional test cases

### v2.0.0 (Planned - Q3 2025)
**Target Features:**
- 📋 Linux detection rules (+20 rules)
- 📋 GitHub Actions CI/CD
- 📋 Automated testing framework
- 📋 Extended documentation suite

---

## 🎓 Academic Context

**This project is a thesis deliverable:**

- **Institution:** University of Adelaide (now Flinders University)
- **Program:** Master of Cyber Security
- **Student:** Roshan Bajracharya
- **Status:** Thesis submission complete

**Primary Deliverables:**
1. ✅ Custom detection rules (rules/)
2. ✅ Visualization dashboard (dashboards/)
3. ✅ D3FEND enrichment (d3fend/)
4. ✅ Validation suite (scripts/)
5. ✅ Thesis document (external)

**Future work is community-driven**, not thesis-required.

---

## ⚠️ Important Notes

### What You Can Use Today
✅ All files in the repository are **production-ready**  
✅ Detection rules are **tested and validated** (92.9% accuracy)  
✅ D3FEND pipeline is **fully functional** (100% enrichment success)  
✅ Dashboard is **performance-optimized** (2.1s query response)  

### What's Still Being Developed
📋 Comprehensive documentation is **in progress**  
📋 Additional deployment scripts are **planned**  
📋 Community contribution framework is **under development**  
📋 Extended test cases are **on the roadmap**  

### Be Aware
⚠️ Limited to **Windows environments** (Linux/macOS rules not yet developed)  
⚠️ Requires **manual installation** (automated installer planned)  
⚠️ Documentation is **minimal** (comprehensive guides in progress)  
⚠️ Community features **not yet implemented** (issue templates, etc.)  

---

## 📧 Questions About Project Structure?

**Current implementation:** See README.md  
**Future roadmap:** See this document (PROJECT_STRUCTURE.md)  
**Contributing:** Open a GitHub Discussion  
**Issues:** Report via GitHub Issues  

---

**Last Updated:** November 2024  
**Document Version:** 1.0.0  
**Project Status:** v1.0.0 Production-Ready, v1.1.0+ Roadmap  

---

**Made with ❤️ for the cybersecurity community**  
*Democratizing advanced threat detection capabilities*