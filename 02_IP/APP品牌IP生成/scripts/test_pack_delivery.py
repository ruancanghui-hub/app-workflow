import subprocess
import tempfile
import unittest
import zipfile
from pathlib import Path


class PackDeliveryTest(unittest.TestCase):
    def test_packs_only_delivery_assets_and_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "brand-ip-delivery"
            root.mkdir()
            (root / "image.png").write_bytes(b"png")
            (root / "notes.md").write_text("ok", encoding="utf-8")
            (root / ".DS_Store").write_bytes(b"junk")
            output = Path(tmp) / "delivery.zip"

            subprocess.run(
                ["python3", str(Path(__file__).with_name("pack_delivery.py")), str(root), str(output)],
                check=True,
            )

            with zipfile.ZipFile(output) as archive:
                names = archive.namelist()
                self.assertIn("brand-ip-delivery/image.png", names)
                self.assertIn("brand-ip-delivery/notes.md", names)
                self.assertIn("brand-ip-delivery/asset-manifest.csv", names)
                self.assertNotIn("brand-ip-delivery/.DS_Store", names)
                self.assertEqual(archive.testzip(), None)


if __name__ == "__main__":
    unittest.main()
