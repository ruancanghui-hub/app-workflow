# Workflow integration

`brand-ip-tabs-to-flutter` is **Phase 4a** — fast path from locked Brand Tab UI to a runnable Flutter shell.

## Pipeline

```
GATE_IP + core_tab_ui
        ↓
minimal Phase 3 docs (if needed) → gates.prototype PASS
        ↓
create-flutter-app → gates.flutter_scaffold PASS
        ↓
shared TabShell + root pages + intervention demo loop
        ↓
implementation-trace.md (honest deferred OS work)
```

## When orchestrator invokes

| Condition | Action |
|---|---|
| User: IP done, build Flutter from Tab UI | Run this skill |
| `/brand-ip-tabs-to-flutter` | Run this skill |
| Normal Phase 4 only (no Tab UI ask) | Use `create-flutter-app` alone |

## Handoff fields

```json
{
  "gates": {
    "prototype": "PASS",
    "flutter_scaffold": "PASS"
  },
  "phases": {
    "flutter": {
      "output_dir": "apps/<slug> or absolute",
      "org": "com.<slug>",
      "project_name": "<slug>",
      "app_id": "<slug>_v1",
      "app_name": "<Name>"
    },
    "features": {
      "implementation_trace": "implementation-trace.md",
      "asset_page_dir": "lib/features/shell/pages/main_shell_page.dart"
    }
  }
}
```

## Validator

```bash
python3 04_Dev/brand-ip-tabs-to-flutter/scripts/validate_brand_tabs_flutter.py \
  docs/workflow/<slug>/handoff-manifest.json
```
