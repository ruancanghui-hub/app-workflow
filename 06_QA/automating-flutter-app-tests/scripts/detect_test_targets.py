#!/usr/bin/env python3
"""List iOS test targets for automated Flutter tests as JSON.

Simulators come from `xcrun simctl list devices --json`; physical iPhones from
`xcrun devicectl list devices`. The `id` field is what `flutter drive -d` expects.
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile


def run_json(cmd: list[str], timeout: int = 60) -> dict | None:
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    except (OSError, subprocess.TimeoutExpired):
        return None
    if result.returncode != 0:
        return None
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return None


def list_simulators(include_shutdown: bool) -> list[dict]:
    data = run_json(["xcrun", "simctl", "list", "devices", "--json"])
    if not data:
        return []
    simulators = []
    for runtime, devices in data.get("devices", {}).items():
        if ".iOS-" not in runtime:
            continue
        os_version = runtime.rsplit(".iOS-", 1)[1].replace("-", ".")
        for device in devices:
            if not device.get("isAvailable", False):
                continue
            booted = device.get("state") == "Booted"
            if not booted and not include_shutdown:
                continue
            simulators.append(
                {
                    "id": device["udid"],
                    "name": device["name"],
                    "os": os_version,
                    "state": device.get("state"),
                    "ready": booted,
                }
            )
    simulators.sort(key=lambda d: (not d["ready"], "iPhone" not in d["name"], d["name"]))
    return simulators


def list_physical_devices() -> list[dict]:
    with tempfile.TemporaryDirectory() as tmp:
        path = os.path.join(tmp, "devices.json")
        try:
            subprocess.run(
                ["xcrun", "devicectl", "list", "devices", "--json-output", path],
                capture_output=True,
                text=True,
                timeout=60,
            )
        except (OSError, subprocess.TimeoutExpired):
            return []
        if not os.path.exists(path):
            return []
        with open(path, encoding="utf-8") as handle:
            try:
                data = json.load(handle)
            except json.JSONDecodeError:
                return []

    devices = []
    for device in data.get("result", {}).get("devices", []):
        hardware = device.get("hardwareProperties", {})
        if hardware.get("platform") != "iOS" or hardware.get("reality") != "physical":
            continue
        connection = device.get("connectionProperties", {})
        properties = device.get("deviceProperties", {})
        tunnel = connection.get("tunnelState")
        developer_mode = properties.get("developerModeStatus")
        paired = connection.get("pairingState") == "paired"
        problems = []
        if not paired:
            problems.append("未配对：在 Xcode → Devices 中信任此电脑")
        if tunnel != "connected":
            problems.append("未连接：用数据线连接并解锁手机")
        if developer_mode != "enabled":
            problems.append("未开启开发者模式：设置 → 隐私与安全性 → 开发者模式")
        devices.append(
            {
                "id": hardware.get("udid") or device.get("identifier"),
                "name": properties.get("name"),
                "model": hardware.get("marketingName") or hardware.get("productType"),
                "os": properties.get("osVersionNumber"),
                "tunnel": tunnel,
                "developer_mode": developer_mode,
                "ready": not problems,
                "problems": problems,
            }
        )
    devices.sort(key=lambda d: not d["ready"])
    return devices


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--all-simulators",
        action="store_true",
        help="include shutdown simulators (default: booted only)",
    )
    args = parser.parse_args()

    if not shutil.which("xcrun"):
        print(json.dumps({"error": "xcrun not found: install Xcode"}, ensure_ascii=False))
        return 1

    simulators = list_simulators(args.all_simulators)
    devices = list_physical_devices()
    ready_sim = next((s for s in simulators if s["ready"]), None)
    ready_device = next((d for d in devices if d["ready"]), None)
    report = {
        "simulators": simulators,
        "devices": devices,
        "applesimutils": bool(shutil.which("applesimutils")),
        "recommended": {
            "simulator": ready_sim["id"] if ready_sim else None,
            "device": ready_device["id"] if ready_device else None,
        },
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if ready_sim else 2


if __name__ == "__main__":
    sys.exit(main())
