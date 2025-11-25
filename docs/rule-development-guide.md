# Rule Development Guide  
Wazuh SIEM Enhancement – Version 1.0

This guide documents the methodology and principles used to create the 26 custom detection rules included in the project.

---

## 1. Design Objectives

The rules were designed to:

- Detect evasive behaviours (LOLBins, fileless techniques, APT-like patterns)
- Minimise false positives through targeted conditions
- Align with MITRE ATT&CK techniques for explainability
- Support D3FEND countermeasure mapping

---

## 2. Engineering Workflow

1. **Threat Selection**  
   - PowerShell encoded commands (T1059.001)  
   - CertUtil misuse (T1105)  
   - WMIC lateral movement (T1047)  
   - Regsvr32 and Rundll32 abuse (T1218.*)  

2. **Data Collection**  
   - Realistic but safe command lines  
   - Vendor and blog examples of attack patterns  
   - Benign baseline commands for comparison  

3. **Pattern Design**  
   - PCRE2 regular expressions for suspicious syntax  
   - Field-based matching on `win.eventdata.*`  
   - Frequency and time-window correlation for bursts  

4. **Severity Calibration**  
   - Level 10–11 for suspicious but uncertain behaviour  
   - Level 12–13 for high-confidence malicious patterns  

5. **ATT&CK Metadata**  
   - `mitre.id` and `mitre.tactic` set per rule  
   - Enables tactic/technique analytics in dashboards  

6. **Validation**  
   - 35-test automated suite  
   - Manual log injection using `wazuh-logtest`  
   - Comparison against baseline Wazuh rules

---

## 3. Example: PowerShell Encoded Commands

Goal: Detect obfuscated or encoded PowerShell use.

Sample patterns:

```regex
(?i)powershell.exe.*EncodedCommand
(?i)powershell.exe.*-enc( |$)
```

Resulting rule:

```xml
<rule id="80110" level="12">
  <if_group>windows</if_group>
  <field name="win.eventdata.commandLine">powershell.exe</field>
  <regex>EncodedCommand|-enc\s</regex>
  <description>Suspicious PowerShell encoded command</description>
  <mitre>
    <id>T1059.001</id>
    <tactic>execution</tactic>
  </mitre>
</rule>
```

---

## 4. Example: CertUtil Download Abuse

Goal: Detect usage of CertUtil for downloading payloads (T1105).

```regex
(?i)certutil.exe.*-urlcache.*-split
```

Example rule:

```xml
<rule id="80120" level="13">
  <if_group>windows</if_group>
  <field name="win.eventdata.commandLine">certutil.exe</field>
  <regex>-urlcache.*-split</regex>
  <description>CertUtil download abuse (potential payload retrieval)</description>
  <mitre>
    <id>T1105</id>
    <tactic>command-and-control</tactic>
  </mitre>
</rule>
```

---

## 5. Correlation and Frequency Rules

Some behaviours are only meaningful when repeated:

- Multiple WMIC executions within 2–5 minutes  
- Repeated Regsvr32 or Rundll32 proxy usage  

Basic correlation structure:

```xml
<rule id="80130" level="12" frequency="3" timeframe="300">
  <if_matched_group>windows</if_matched_group>
  <match>wmic.exe</match>
  <description>Repeated WMIC execution (potential lateral movement)</description>
  <mitre>
    <id>T1047</id>
    <tactic>lateral-movement</tactic>
  </mitre>
</rule>
```

---

## 6. Future Rule Extensions

Potential enhancements:

- Add Linux-specific rules (e.g., bash history abuse, curl/wget chains)  
- Extend to cloud control-plane logs (AWS, Azure)  
- Use multi-field conditions (user, host, parent process)  
- Introduce allowlists for known administrative scripts to further reduce false positives.
