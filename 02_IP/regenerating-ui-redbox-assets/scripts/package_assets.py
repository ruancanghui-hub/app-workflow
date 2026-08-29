#!/usr/bin/env python3
"""Create manifest.json and zip a code-ready asset folder."""
import json, struct, sys, zipfile
from pathlib import Path

GROUPS = ['backgrounds','feature_art','nav_icons','status','ui_controls']

def png_metadata(path: Path):
    """Read PNG dimensions and alpha capability without optional dependencies."""
    with path.open('rb') as image:
        header = image.read(26)
    if header[:8] != b'\x89PNG\r\n\x1a\n' or header[12:16] != b'IHDR':
        raise ValueError(f'Expected a PNG file: {path}')
    width, height, _bit_depth, color_type = struct.unpack('>IIBB', header[16:26])
    return width, height, color_type in (4, 6)

def main(root_s: str, zip_s: str | None = None):
    root = Path(root_s)
    root.mkdir(parents=True, exist_ok=True)
    for g in GROUPS:
        (root/g).mkdir(exist_ok=True)
    entries=[]
    for g in GROUPS:
        for p in sorted((root/g).glob('*.png')):
            width, height, transparent = png_metadata(p)
            entries.append({
                'filename': p.name,
                'group': g,
                'source_role': p.stem,
                'width': width,
                'height': height,
                'transparent': transparent,
                'transparency_expected': transparent,
                'regenerated': g == 'backgrounds',
                'notes': 'Regenerated background asset.' if g == 'backgrounds' else 'Red-box asset export.',
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
