# Configuration Reference  
Wazuh SIEM Enhancement – Version 1.0

This document summarises the most important configuration components used by the enhanced Wazuh deployment.

---

## 1. Wazuh Rules Configuration

The enhanced `local_rules.xml` includes:

- 26 custom rules targeting:
  - PowerShell obfuscation
  - CertUtil download abuse
  - WMIC-based lateral movement
  - Regsvr32, Rundll32 LOLBins
  - Fileless/command-based behaviours
- ATT&CK metadata (`rule.mitre.id`, `rule.mitre.tactic`)
- Calibrated severities (levels 10–13)

Example snippet:

```xml
<rule id="80101" level="12">
  <decoded_as>windows</decoded_as>
  <field name="win.eventdata.commandLine">powershell.exe</field>
  <regex>EncodedCommand|IEX</regex>
  <description>Suspicious PowerShell encoded command</description>
  <mitre>
    <id>T1059.001</id>
    <tactic>execution</tactic>
  </mitre>
</rule>
```

---

## 2. Elasticsearch Ingest Pipeline (D3FEND Enrichment)

Pipeline definition is stored in:

```text
d3fend/d3fend-enrichment-pipeline.json
```

Key elements:

- Reads ATT&CK technique from the alert
- Looks up mapping in `mitre-d3fend-mapping-398.json`
- Adds structured D3FEND fields:

  - `d3fend.actions`
  - `d3fend.description`
  - `d3fend.implementation`
  - `d3fend.priority`
  - `d3fend.mapping_type`

The pipeline uses hierarchical fallback:

1. Exact technique match (e.g., T1059.001)  
2. Parent technique (e.g., T1059)  
3. Tactic-level default  
4. Global default mapping

---

## 3. Mapping Database Structure

File:

```text
d3fend/mitre-d3fend-mapping-398.json
```

Each JSON entry includes:

```json
{
  "attack_id": "T1059.001",
  "d3fend_id": "D3-PSH-001",
  "actions": ["Block PowerShell encoded commands", "Restrict script execution policy"],
  "description": "Mitigations for malicious PowerShell usage.",
  "implementation": "Use constrained language mode, enable script block logging, and baseline legitimate scripts.",
  "priority": "high",
  "mapping_type": "exact"
}
```

---

## 4. Grafana Dashboard Configuration

Dashboard JSON:

```text
dashboards/wazuh-mitre-advanced-threat-dashboard.json
```

Logical sections:

1. ATT&CK tactic/technique coverage  
2. LOLBin detection (per binary and host)  
3. Fileless malware indicators  
4. Host risk scoring view  
5. Inline D3FEND guidance panels  

Most panels filter on:

- `rule.mitre.id`
- `rule.mitre.tactic`
- `agent.name`
- `rule.level`

---

## 5. Agent Telemetry

Windows agents:

- Security log with Event ID 4688 (process creation)  
- PowerShell Operational log  
- (Optional) Sysmon Operational log  

Linux agents:

- Syslog, auth logs, and command auditing where available  

---

## 6. Recommended Retention and Performance Settings

Suggested index settings for `wazuh-alerts-*`:

- `refresh_interval: 30s`  
- `max_result_window: 20000`  
- Roll over or delete indices older than 30–60 days  

Tuning should be adapted to your environment size and compliance requirements.
