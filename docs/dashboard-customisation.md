# Dashboard Customisation Guide  
Wazuh SIEM Enhancement – Version 1.0

This guide explains how to customise and extend the advanced Grafana dashboard included with the project.

---

## 1. Dashboard Structure

The main dashboard JSON file is:

```text
dashboards/wazuh-mitre-advanced-threat-dashboard.json
```

Logical sections include:

1. **ATT&CK Overview**  
   - Tactic distribution  
   - Technique coverage  

2. **LOLBins Activity**  
   - Per-binary usage  
   - Per-host breakdown  

3. **Fileless Indicators**  
   - Encoded PowerShell  
   - Suspicious command-line usage  

4. **Host Risk Scoring**  
   - Composite risk score per host  
   - Metric contributions (volume, severity, tactic diversity, technique variety)  

5. **D3FEND Guidance**  
   - Panels surfacing `d3fend.*` fields  
   - Helps analysts move from detection to response faster  

---

## 2. Editing Panels

To modify a panel:

1. Open the dashboard in Grafana.  
2. Hover over a panel → click the panel title → **Edit**.  
3. Adjust:
   - Query (Lucene, KQL, or DSL)
   - Visualisation type (table, time series, bar chart, stat)  
   - Field overrides, thresholds, and legend  

4. Click **Apply** and then **Save dashboard**.

---

## 3. Common Query Fields

Typical filters used:

- `rule.mitre.id` – filter for a specific ATT&CK technique  
- `rule.mitre.tactic` – filter by tactic (e.g., `defense-evasion`)  
- `agent.name` – focus on a particular host  
- `rule.level` – filter by severity  

Example Lucene query:

```text
rule.mitre.id:T1059.001 AND agent.name:"SERVER01"
```

---

## 4. Adding New Panels

To add a new panel for a newly created rule:

1. Ensure the new rule is deployed and generating alerts.  
2. In Grafana → open the main dashboard.  
3. Click **Add panel → Add a new panel**.  
4. Set query, e.g.:

```text
rule.id: 80150
```

5. Choose visualisation (e.g., *Time series* or *Table*).  
6. Save the panel and dashboard.

---

## 5. Host Risk Score

If the dashboard includes host risk scoring:

- Risk is typically a function of:
  - Alert volume per host  
  - Severity distribution  
  - Tactic diversity  
  - Technique variety  

The exact formula can be inspected by examining the panel’s query and transformations.  
You can adjust weightings by editing the queries or calculations in the risk panels.

---

## 6. Performance Tips

- Use shorter dashboard time windows (e.g., last 1h or 6h).  
- Limit panel transformations that require full dataset scans.  
- For high-volume environments, consider dedicated views per host or per tactic.  
- Use Grafana’s **Query Inspector** to see actual query duration and response size.

---

## 7. Exporting and Versioning

- Use **Dashboard → Settings → JSON Model** to export and version-control dashboard JSON.  
- Store customised JSON under `dashboards/` with a clear naming convention, e.g.:

```text
dashboards/wazuh-mitre-advanced-threat-dashboard-v2.json
```

This allows safe rollback and sharing of custom dashboard configurations.
