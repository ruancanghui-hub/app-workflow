import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("validate_handoff.py")
SPEC = importlib.util.spec_from_file_location("validate_handoff", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


def manifest(requested: bool, status: str) -> dict:
    return {
        "schema_version": 2,
        "product_slug": "demo",
        "workflow": {},
        "intake": {},
        "metadata": {key: "x" for key in MODULE.REQUIRED_METADATA},
        "mvp_loop": "loop",
        "phases": {
            "prd": {"dir": ".", "files": {}},
            "brand": {
                "delivery_dir": ".",
                "direction_id": "a",
                "tab_ui_direction": "a",
                "core_tab_ui_requested": requested,
                "core_tab_ui_status": status,
                "deferred_root_tabs": [],
            },
        },
        "gates": {gate: ("PASS" if gate in ("prd", "ip") else "PENDING") for gate in MODULE.GATE_ORDER},
        "domain_docs": {},
    }


class HandoffCoreTabTest(unittest.TestCase):
    def test_unrequested_core_expansion_does_not_block_ip_gate(self):
        with tempfile.TemporaryDirectory() as raw:
            errors = MODULE.validate(manifest(False, "NOT_REQUESTED"), Path(raw) / "handoff.json")
            self.assertEqual([], errors)

    def test_requested_core_expansion_requires_contract_paths(self):
        with tempfile.TemporaryDirectory() as raw:
            errors = MODULE.validate(manifest(True, "PASS"), Path(raw) / "handoff.json")
            self.assertTrue(any("tab_ui_reference required" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
