# Troubleshooting FAQ  
Wazuh SIEM Enhancement – Version 1.0

This FAQ covers common issues encountered during deployment and operation of the enhanced Wazuh SIEM platform.

---

## 1. No Alerts Appearing in Dashboard

**Possible causes:**

- Agents are not sending logs  
- Indices are not being created in Elasticsearch  
- Time range in Grafana is too narrow

**Checks:**

```bash
/var/ossec/bin/agent_control -l
curl -X GET "localhost:9200/_cat/indices/wazuh-alerts-*?v"
```

**Fixes:**

- Ensure agents are connected and started  
- Check Wazuh manager logs for ingestion errors  
- Expand Grafana time range (e.g., last 24 hours)

---

## 2. Custom Rules Not Triggering

**Checks:**

```bash
sudo /var/ossec/bin/wazuh-logtest -t
ls -l /var/ossec/etc/rules/local_rules.xml
grep -n "rule id="80" /var/ossec/etc/rules/local_rules.xml | head
```

**Common issues:**

- Syntax errors in `local_rules.xml`  
- Missing `<include>local_rules.xml</include>` in `ossec.conf`  
- Incorrect field names (e.g., wrong `win.eventdata.*` path)

---

## 3. D3FEND Fields Missing

**Checks:**

```bash
curl -X GET "localhost:9200/_ingest/pipeline/d3fend-enrichment?pretty"
curl -X GET "localhost:9200/wazuh-alerts-*/_search?pretty" -d '{"size":1}'
```

**Fixes:**

- Reinstall pipeline using project script (if provided)  
- Confirm that the ingest pipeline is attached to the target index template  
- Validate `mitre-d3fend-mapping-398.json` JSON syntax using `jq`  

---

## 4. Dashboard Extremely Slow

**Possible causes:**

- Very large time window (weeks/months)  
- Very high document count in `wazuh-alerts-*`  
- Insufficient Elasticsearch heap memory  

**Mitigations:**

- Limit dashboards to last few hours/days  
- Implement index lifecycle policies (delete or move old indices)  
- Increase ES heap and restart the service  

---

## 5. High False-Positive Rates

**Approach:**

- Identify top noisy rules using an aggregation query  
- Consider:
  - Lowering severity level  
  - Adding more specific conditions (e.g., restricting to certain users/paths)  
  - Introduce exceptions (allowlist known benign tools/scripts)

Example query:

```bash
curl -X GET "localhost:9200/wazuh-alerts-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "by_rule": {
      "terms": { "field": "rule.id", "size": 20 }
    }
  }
}'
```

---

## 6. Grafana Cannot Connect to Elasticsearch

**Checks:**

```bash
systemctl status elasticsearch
curl -X GET "http://localhost:9200"
```

Ensure:

- Correct URL in Grafana datasource (e.g., `http://localhost:9200`)  
- No firewall blocking port 9200  
- Elasticsearch is running and healthy  

---

If an issue persists, capture:

- Relevant log snippets  
- Exact error messages  
- Steps to reproduce  

…and open an issue in the project’s GitHub repository.
