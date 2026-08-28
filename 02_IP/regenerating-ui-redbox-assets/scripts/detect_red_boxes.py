#!/usr/bin/env python3
"""Detect red annotation rectangles in a screenshot.

Usage:
  python detect_red_boxes.py input.png
Outputs JSON with approximate bounding boxes. Pillow + numpy only.
"""
import json, sys
from collections import deque
from pathlib import Path
import numpy as np
from PIL import Image


def detect(path: str):
    img = np.array(Image.open(path).convert('RGB'))
    r, g, b = img[...,0], img[...,1], img[...,2]
    # tolerant red annotation threshold
    mask = (r >= 190) & (r >= g * 1.6) & (r >= b * 1.4) & (g <= 150)
    h, w = mask.shape
    seen = np.zeros_like(mask, dtype=bool)
    comps = []
    for y in range(h):
        for x in range(w):
            if not mask[y, x] or seen[y, x]:
                continue
            q = deque([(x, y)])
            seen[y, x] = True
            xs, ys = [], []
            while q:
                cx, cy = q.popleft(); xs.append(cx); ys.append(cy)
                for nx, ny in ((cx+1,cy),(cx-1,cy),(cx,cy+1),(cx,cy-1)):
                    if 0 <= nx < w and 0 <= ny < h and mask[ny,nx] and not seen[ny,nx]:
                        seen[ny,nx] = True; q.append((nx,ny))
            if len(xs) >= 20:
                comps.append([min(xs), min(ys), max(xs), max(ys), len(xs)])

    # Keep annotation-sized components; callers can merge nearby fragments visually.
    boxes = []
    for x1,y1,x2,y2,n in comps:
        bw, bh = x2-x1+1, y2-y1+1
        if bw >= 12 and bh >= 12:
            boxes.append({"x":x1,"y":y1,"width":bw,"height":bh,"red_pixels":n})
    boxes.sort(key=lambda d:(d['y'], d['x']))
    return {"image":{"width":w,"height":h},"boxes":boxes}

if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise SystemExit('Usage: detect_red_boxes.py input.png')
    print(json.dumps(detect(sys.argv[1]), ensure_ascii=False, indent=2))
