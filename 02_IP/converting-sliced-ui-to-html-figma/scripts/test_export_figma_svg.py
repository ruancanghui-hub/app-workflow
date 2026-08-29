import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("export_figma_svg.py")


class ExportFigmaSvgTests(unittest.TestCase):
    def test_exports_self_contained_fixed_canvas_svg(self):
        spec = importlib.util.spec_from_file_location("export_figma_svg", SCRIPT)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)

        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "screen.png"
            source.write_bytes(b"\x89PNG\r\n\x1a\nmock")
            output = root / "screen.svg"

            module.export_svg(source, output, 941, 1672)

            svg = output.read_text(encoding="utf-8")
            self.assertIn('viewBox="0 0 941 1672"', svg)
            self.assertIn('width="941"', svg)
            self.assertIn('height="1672"', svg)
            self.assertIn("data:image/png;base64,", svg)


if __name__ == "__main__":
    unittest.main()
