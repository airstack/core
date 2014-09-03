Example custom service.

```json
"services": {
  "myapp": {
    "enable": "",
    "disable": "",
    "run": "while true; do echo \"HELLO \"airstack-base\"\"; sleep 1; done",
    "check": "true",
    "finish": "echo \"finished\"",
    "log": "exec chpst -u root logger -t $SERVICE_NAME -p local0.notice",
    "tags": ["main-service"],
    "input": [],
    "output": []
  }
}
```
