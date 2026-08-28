#!/usr/bin/env python3
"""Create manifest.json and zip a code-ready asset folder."""
import json, sys, zipfile
from pathlib import Path
from PIL import Image

GROUPS = ['backgrounds','feature_art','nav_icons','status','ui_controls']

def main(root_s: str, zip_s: str | None = None):
    root = Path(root_s)
    root.mkdir(parents=True, exist_ok=True)
    for g in GROUPS:
        (root/g).mkdir(exist_ok=True)
    entries=[]
    for g in GROUPS:
        for p in sorted((root/g).glob('*.png')):
            im=Image.open(p)
            entries.append({
                'filename': p.name,
                'group': g,
                'width': im.width,
                'height': im.height,
                'mode': im.mode,
                'transparent': 'A' in im.mode,
            })
    manifest={'asset_count':len(entries),'groups':GROUPS,'assets':entries}
    (root/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
    zip_path = Path(zip_s) if zip_s else root.with_suffix('.zip')
    with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED) as z:
        for p in sorted(root.rglob('*')):
            if p.is_file(): z.write(p, p.relative_to(root.parent))
    print(zip_path)

if __name__=='__main__':
    if len(sys.argv) not in (2,3):
        raise SystemExit('Usage: package_assets.py assets_dir [output.zip]')
    main(sys.argv[1], sys.argv[2] if len(sys.argv)==3 else None)
