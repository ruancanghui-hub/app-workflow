# Workflow integration

`commercial-analysis-to-app-coverage` is **Phase BA / 1a** — BA intake + decision alignment, then Phase 1 PRD. Shares `gates.prd` with `creating-app-product-docs`.

## Pipeline position

```
商业分析.md
        ↓
commercial-analysis-to-app-coverage   [extract + decide + handoff seed]
        ↓
creating-app-product-docs             [five files + validate_product_docs]
        ↓
GATE_PRD (gates.prd = PASS)
        ↓
Phase 2+ only when user continues /app-workflow
```

## When the orchestrator invokes this skill

| Condition | Action |
|---|---|
| User attaches/only supplies 商业分析 / business analysis | Run this skill first |
| User invokes `/commercial-analysis-to-app-coverage` | Run this skill |
| User gives one-sentence intake without BA file | Skip this skill; use normal Phase 1 intake |
| `gates.prd` already PASS and no new BA | Do not rerun unless user requests refresh (new product dir suffix) |

## Locked scope

1. Stops at **GATE_PRD** — no brand IP, prototype, or Flutter.
2. Does **not** reimplement PRD file prose — delegates to `creating-app-product-docs`.
3. BA embedded PRD tables are input only.
4. Handoff path checks are relative to `docs/workflow/<slug>/handoff-manifest.json` parent (same as `validate_handoff.py`).

## Handoff fields (after success)

```json
{
  "workflow": {
    "phase": "PHASE_2_IP",
    "mode": "智能模式 | 深度访谈模式"
  },
  "intake": {
    "one_liner": "...",
    "competitors": [],
    "platform": "...",
    "inferences": []
  },
  "metadata": {
    "产品名": "",
    "模式": "",
    "平台": "",
    "目标用户": "",
    "商业策略": ""
  },
  "mvp_loop": "...",
  "gates": { "prd": "PASS" },
  "phases": {
    "prd": {
      "dir": "../../product/YYYY-MM-DD-Name",
      "files": {
        "功能清单": "../../product/.../01-功能清单.md",
        "PRD": "../../product/.../02-PRD.md",
        "MVP范围": "../../product/.../03-MVP范围.md",
        "sources": "../../product/.../sources.md",
        "assumptions": "../../product/.../assumptions.md"
      }
    }
  }
}
```

During BA alignment (before PRD PASS), set `workflow.phase` to `PHASE_BA_COVERAGE`.

## Validators

```bash
python3 "$APP_WORKFLOW_ROOT/01_PRD/creating-app-product-docs/scripts/validate_product_docs.py" \
  <product-dir>

python3 "$APP_WORKFLOW_ROOT/00_Orchestrator/app-workflow/scripts/validate_handoff.py" \
  docs/workflow/<slug>/handoff-manifest.json

python3 "$APP_WORKFLOW_ROOT/01_PRD/commercial-analysis-to-app-coverage/scripts/validate_ba_coverage.py" \
  docs/workflow/<slug>/handoff-manifest.json
```

## Gate relationship

| Check | Owner |
|---|---|
| BA extract + consensus | this skill |
| Five product docs structure | `creating-app-product-docs` |
| Handoff gate consistency | `validate_handoff.py` |
| Coverage bundle (prd PASS + files + mvp_loop) | `validate_ba_coverage.py` |
