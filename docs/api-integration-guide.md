# API Integration Guide  
Wazuh SIEM Enhancement – Version 1.0

This guide describes how to interact programmatically with the enhanced Wazuh deployment and Elasticsearch for automation and integration.

---

## 1. Wazuh API Basics

If the Wazuh API is enabled, you can authenticate and list agents or alerts programmatically.

Example: test authentication

```bash
curl -k -u user:password "https://<wazuh-host>:55000/security/user/authenticate"
```

Refer to official Wazuh documentation for full API usage. The enhancement project focuses mainly on:

- Rule-driven enrichment  
- Elasticsearch-based analytics  
- D3FEND pipeline output  

---

## 2. Querying Enriched Alerts from Elasticsearch

Basic example:

```bash
curl -X GET "http://localhost:9200/wazuh-alerts-*/_search?pretty"   -H 'Content-Type: application/json' -d'
{
  "query": {
    "range": {
      "timestamp": {
        "gte": "now-1h"
      }
    }
  },
  "size": 10,
  "sort": [{ "timestamp": "desc" }]
}
'
```

Look for:

- `rule.mitre.id` – ATT&CK technique  
- `d3fend.actions` – suggested countermeasures  

---

## 3. Programmatic Access (Python Example)

```python
import requests

ES_URL = "http://localhost:9200/wazuh-alerts-*/_search"

query = {
    "size": 5,
    "sort": [{"timestamp": "desc"}],
    "query": {"match_all": {}}
}

resp = requests.get(ES_URL, json=query)
resp.raise_for_status()

for hit in resp.json()["hits"]["hits"]:
    src = hit["_source"]
    print(src.get("rule", {}).get("id"), src.get("rule", {}).get("description"))
    print("ATT&CK:", src.get("rule", {}).get("mitre", {}))
    print("D3FEND:", src.get("d3fend", {}))
    print("---")
```

This example pulls the most recent alerts and prints their ATT&CK and D3FEND context.

---

## 4. Integration with SOAR/SIEM Pipelines

External tools (e.g., Shuffle SOAR, TheHive, custom Python scripts) can:

- Poll for new high-severity alerts  
- Parse ATT&CK and D3FEND metadata  
- Trigger playbooks (e.g., isolate host, disable account, block hash)  

Common integration pattern:

1. Poll Elasticsearch for new alerts with `rule.level >= 12`  
2. Extract host, user, ATT&CK technique, D3FEND actions  
3. Map to response playbooks in the SOAR platform  

---

## 5. Simulating the D3FEND Pipeline

You can test pipeline behaviour using the `_simulate` endpoint:

```bash
curl -X POST "localhost:9200/_ingest/pipeline/d3fend-enrichment/_simulate"   -H 'Content-Type: application/json' -d'
{
  "docs": [
    {
      "_source": {
        "rule": {
          "mitre": {
            "id": "T1059.001"
          }
        }
      }
    }
  ]
}
'
```

The response should show the enriched `d3fend.*` fields that would be added to a live alert.

---

## 6. Exporting Alerts to Other Systems

For environments that require long-term retention in a data warehouse or SIEM, you can periodically export enriched alerts from Elasticsearch to:

- PostgreSQL  
- Data lakes (e.g., S3, GCS)  
- Other SIEM platforms  

Export can be implemented using:

- Logstash or Beats pipelines  
- Custom Python scripts using the scroll or search\_after APIs  

The enhancement project provides the enriched semantic content (ATT&CK + D3FEND); integration is then environment-specific.
