#!/usr/bin/env python3
import argparse
import csv
import hashlib
import struct
import zipfile
from pathlib import Path

SKIP = {".DS_Store", "Thumbs.db", "asset-manifest.csv"}


def png_size(path: Path):
    if path.suffix.lower() != ".png":
        return "", ""
    with path.open("rb") as stream:
        header = stream.read(24)
    if header[:8] != b"\x89PNG\r\n\x1a\n":
        return "", ""
    return struct.unpack(">II", header[16:24])


def digest(path: Path):
    sha = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            sha.update(chunk)
    return sha.hexdigest()


def pack(root: Path, output: Path):
    if not root.is_dir():
        raise SystemExit(f"Delivery directory not found: {root}")
    files = sorted(p for p in root.rglob("*") if p.is_file() and p.name not in SKIP)
    manifest = root / "asset-manifest.csv"
    with manifest.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(["file", "bytes", "width", "height", "sha256"])
        for path in files:
            width, height = png_size(path)
            writer.writerow([path.relative_to(root), path.stat().st_size, width, height, digest(path)])
    files.append(manifest)
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for path in files:
            archive.write(path, Path(root.name) / path.relative_to(root))
    with zipfile.ZipFile(output) as archive:
        bad = archive.testzip()
        if bad:
            raise SystemExit(f"ZIP verification failed: {bad}")
    print(output.resolve())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Manifest and ZIP an App brand-IP delivery directory")
    parser.add_argument("delivery_dir", type=Path)
    parser.add_argument("output_zip", type=Path)
    args = parser.parse_args()
    pack(args.delivery_dir.resolve(), args.output_zip.resolve())
