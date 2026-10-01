#!/usr/bin/env python3
"""Resolve an OrcaSlicer profile's `inherits` chain into one flat JSON.

The OrcaSlicer CLI does not walk `inherits`. It reads the leaf file, takes the
keys written there, and silently falls back to its own compiled-in defaults for
everything else. Two consequences seen on this printer:

  * PolyTerra PLA declares no temperatures of its own, so it sliced at 200 C
    instead of the 220 C its grandparent specifies - a cold print, no warning.
  * The KE process profile inherits `exclude_object = 1` and sliced with 0,
    losing Klipper's per-object cancellation.

Neither errors. This walks the chain and merges parent-under-child so the CLI
gets a profile with nothing left to resolve.

    flatten-profile.py <profile.json> [-o out.json] [--set key=value]
"""

import argparse
import json
import os
import sys

SYSTEM = os.path.expanduser("~/Library/Application Support/OrcaSlicer/system")

# Keys describing a profile's place in the hierarchy rather than its settings.
# Once flattened they are meaningless or actively misleading.
STRIP = {"inherits", "instantiation", "from", "setting_id", "renamed_from"}


def build_index():
    """Map every system profile name to the file(s) defining it.

    A bare name like `fdm_filament_pla` is defined in more than one vendor
    tree, with different values - Creality's wants a 60 C bed, Orca's library
    55 C. Which one is right depends on where the chain started, so keep all
    candidates and let the caller pick by proximity.
    """
    index = {}
    for root, _, files in os.walk(SYSTEM):
        for fname in files:
            if fname.endswith(".json"):
                index.setdefault(fname[:-5], []).append(
                    os.path.join(root, fname))
    return index


def shared_prefix(a, b):
    """How many leading path segments two files agree on."""
    pa, pb = a.split(os.sep), b.split(os.sep)
    n = 0
    for x, y in zip(pa, pb):
        if x != y:
            break
        n += 1
    return n


def find_parent(name, child_path, index):
    """Resolve a parent by name, preferring the copy nearest the child."""
    sibling = os.path.join(os.path.dirname(child_path), name + ".json")
    if os.path.isfile(sibling):
        return sibling
    candidates = index.get(name, [])
    if not candidates:
        return None
    return max(candidates, key=lambda p: shared_prefix(p, child_path))


def flatten(leaf):
    """Merge the chain leaf-last, so a child always overrides its parent."""
    index = build_index()
    chain, path, seen = [], os.path.abspath(leaf), set()

    while path:
        if path in seen:
            raise SystemExit(f"circular inherits at {path}")
        seen.add(path)
        with open(path) as fh:
            node = json.load(fh)
        chain.append(node)
        parent = node.get("inherits")
        if not parent:
            break
        found = find_parent(parent, path, index)
        if not found:
            raise SystemExit(f"cannot resolve inherits '{parent}' from {path}")
        path = found

    merged = {}
    for node in reversed(chain):
        merged.update(node)
    for key in STRIP:
        merged.pop(key, None)

    # Keep the leaf's identity: the GUI matches projects to presets by name.
    merged["name"] = chain[0].get("name", merged.get("name", ""))
    # `from` must stay as the leaf declared it. Marking a flattened *machine*
    # profile as "User" makes the CLI reject it - it then expects the preset to
    # reference an installed system printer - and it fails with nothing but
    # "run found error, exit".
    merged["from"] = chain[0].get("from", "User")
    merged["instantiation"] = "true"
    return merged, len(chain)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("profile")
    ap.add_argument("-o", "--output")
    ap.add_argument("--set", action="append", default=[], metavar="KEY=VALUE",
                    help="override a key after flattening (repeatable)")
    ap.add_argument("--report", action="store_true",
                    help="print a one-line summary to stderr")
    args = ap.parse_args()

    merged, depth = flatten(args.profile)

    for override in args.set:
        key, _, value = override.partition("=")
        merged[key] = value

    if args.report:
        def first(key):
            val = merged.get(key)
            return val[0] if isinstance(val, list) and val else val
        bits = [f"{depth} profiles"]
        if "nozzle_temperature" in merged:
            bits.append(f"nozzle {first('nozzle_temperature')}C")
            bits.append(f"bed {first('hot_plate_temp')}C")
            bits.append(f"{first('filament_vendor')}")
        elif "layer_height" in merged:
            bits.append(f"layer {first('layer_height')}mm")
            bits.append(f"bed type {first('curr_bed_type')}")
        print(f"   flattened {os.path.basename(args.profile)[:-5]}: "
              + ", ".join(bits), file=sys.stderr)

    if args.output:
        with open(args.output, "w") as fh:
            json.dump(merged, fh, indent=1)
    else:
        json.dump(merged, sys.stdout, indent=1)


if __name__ == "__main__":
    main()
