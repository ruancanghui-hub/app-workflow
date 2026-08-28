#!/usr/bin/env python3
from pathlib import Path
import re, sys

REQUIRED = [
    'docs/prototype/00-需求追溯矩阵.md', 'docs/prototype/01-低保真原型说明.md',
    'docs/prototype/02-交互说明文档.md', 'docs/prototype/03-页面跳转逻辑图.md',
    'docs/prototype/04-原型评审清单.md'
]
BAD = re.compile(r'\b(?:TODO|TBD|FIXME)\b|待定|待补充', re.I)

def fail(message):
    print(f'FAIL: {message}')
    raise SystemExit(1)

def main():
    if len(sys.argv) != 2:
        fail('usage: validate_prototype_package.py <project-root>')
    root = Path(sys.argv[1]).resolve()
    for rel in REQUIRED:
        path = root / rel
        if not path.is_file(): fail(f'missing {rel}')
        if BAD.search(path.read_text(encoding='utf-8')): fail(f'unresolved placeholder in {rel}')
    for html in (root / 'prototype').rglob('*.html') if (root / 'prototype').exists() else []:
        text = html.read_text(encoding='utf-8')
        if text.count('data-codex-root') != 1: fail(f'{html.relative_to(root)} needs one data-codex-root')
        ids = re.findall(r'data-codex-id=["\']([^"\']+)["\']', text)
        if len(ids) != len(set(ids)): fail(f'duplicate data-codex-id in {html.relative_to(root)}')
    print('Prototype package is valid!')

if __name__ == '__main__': main()
