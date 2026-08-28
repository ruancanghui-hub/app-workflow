import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("validate_core_tab_ui.py")
SPEC = importlib.util.spec_from_file_location("validate_core_tab_ui", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


def png(width: int, height: int) -> bytes:
    return b"\x89PNG\r\n\x1a\n" + b"\x00" * 8 + width.to_bytes(4, "big") + height.to_bytes(4, "big")


class CoreTabValidatorTest(unittest.TestCase):
    def test_valid_contract_passes(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            source = root / "source.png"
            source.write_bytes(png(853, 1844))
            core = root / "core_tab_ui"
            core.mkdir()
            (core / "qa-report.md").write_text("PASS", encoding="utf-8")
            html = root / "index.html"
            markup = '<section data-screen="home"></section><section data-screen="library"></section><nav data-codex-id="root-tabbar" data-tab-contract="shared-active-only"><button data-tab="home"><b>首页</b></button><button data-tab="library"><b>内容</b></button></nav>'
            html.write_text(markup, encoding="utf-8")
            (core / "tab-home.png").write_bytes(source.read_bytes())
            (core / "tab-library.png").write_bytes(source.read_bytes())
            (core / "00-style-lock.md").write_text("首页 内容", encoding="utf-8")
            self.assertEqual([], MODULE.validate(source, core, [("home", "首页"), ("library", "内容")], html))

    def test_dimension_drift_fails(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            source = root / "source.png"
            source.write_bytes(png(853, 1844))
            core = root / "core_tab_ui"
            core.mkdir()
            for name in ("tonight", "sounds", "sleep", "profile"):
                (core / f"tab-{name}.png").write_bytes(source.read_bytes())
            (core / "tab-sleep.png").write_bytes(png(864, 1821))
            (core / "00-style-lock.md").write_text("今晚 声音 睡眠 我的", encoding="utf-8")
            (core / "qa-report.md").write_text("PASS", encoding="utf-8")
            errors = MODULE.validate(source, core, [("tonight", "今晚"), ("sounds", "声音"), ("sleep", "睡眠"), ("profile", "我的")], None)
            self.assertTrue(any("canvas mismatch" in error for error in errors))

    def test_duplicate_tab_ids_fail(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            errors = MODULE.validate(root / "source.png", root, [("home", "首页"), ("home", "内容")], None)
            self.assertEqual(["tab IDs must be unique"], errors)


if __name__ == "__main__":
    unittest.main()
