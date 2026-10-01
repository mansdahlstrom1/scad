#!/usr/bin/env python3
"""Set project-scope settings inside an exported OrcaSlicer .3mf.

`--export-3mf` honours the loaded presets for most keys but writes a few
project-scope ones from its own defaults, ignoring what was passed in. The
plate is the one that matters here: it always comes out "Cool Plate", so the
GUI heats the bed to 35 C for a filament that asked for 55 C.

Rewriting the archive is the only way in - a zip entry cannot be replaced in
place.

    patch-3mf.py project.3mf --set curr_bed_type="Textured PEI Plate"
"""

import argparse
import json
import os
import shutil
import tempfile
import zipfile

SETTINGS = "Metadata/project_settings.config"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("project")
    ap.add_argument("--set", action="append", default=[], metavar="KEY=VALUE",
                    help="project setting to force (repeatable)")
    ap.add_argument("--report", action="store_true")
    args = ap.parse_args()

    overrides = dict(o.partition("=")[::2] for o in args.set)
    if not overrides:
        return

    with zipfile.ZipFile(args.project) as zf:
        entries = zf.infolist()
        contents = {e.filename: zf.read(e.filename) for e in entries}

    if SETTINGS not in contents:
        raise SystemExit(f"{args.project} has no {SETTINGS}")

    settings = json.loads(contents[SETTINGS])
    changed = {k: v for k, v in overrides.items() if settings.get(k) != v}
    settings.update(overrides)
    contents[SETTINGS] = json.dumps(settings, indent=1).encode()

    # Write beside the original so the replace is atomic on the same volume.
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(os.path.abspath(
        args.project)), suffix=".3mf")
    os.close(fd)
    with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zf:
        for entry in entries:
            zf.writestr(entry.filename, contents[entry.filename])
    shutil.move(tmp, args.project)

    if args.report and changed:
        for key, value in changed.items():
            print(f"   set {key} = {value}")


if __name__ == "__main__":
    main()
