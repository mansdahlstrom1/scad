#!/usr/bin/env bash
# Render a .scad and wrap it in an OrcaSlicer project (.3mf) with print
# settings already applied, ready to open, preview and print.
#
#   tools/prepare-print.sh Plektrum/Plektrum.scad
#   tools/prepare-print.sh part.scad --process Fine --filament PETG
#   tools/prepare-print.sh part.scad -D 'width=42' -D 'height=10'
#
# Writes <name>.stl and <name>.3mf next to the .scad, in the project folder.
# Open the .3mf in OrcaSlicer, slice, preview, print.

set -euo pipefail

OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
ORCA="/Applications/OrcaSlicer.app/Contents/MacOS/OrcaSlicer"
SYS="$HOME/Library/Application Support/OrcaSlicer/system/Creality"

NOZZLE="0.4"
PROCESS="Standard"     # Fine 0.12 | Optimal 0.16 | Standard 0.20 | Draft 0.24
FILAMENT="PolyTerra"   # the spool normally loaded
OUTDIR=""          # defaults to the input file's own folder
declare -a SCAD_DEFS=()

usage() { sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

[[ $# -eq 0 ]] && usage 1
INPUT="$1"; shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --process)  PROCESS="$2"; shift 2 ;;
    --filament) FILAMENT="$2"; shift 2 ;;
    --nozzle)   NOZZLE="$2"; shift 2 ;;
    --outdir)   OUTDIR="$2"; shift 2 ;;
    -D)         SCAD_DEFS+=(-D "$2"); shift 2 ;;
    -h|--help)  usage 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

case "$PROCESS" in
  Fine)     PROC_FILE="0.12mm Fine @Creality Ender3V3KE.json" ;;
  Optimal)  PROC_FILE="0.16mm Optimal @Creality Ender3V3KE.json" ;;
  Standard) PROC_FILE="0.20mm Standard @Creality Ender3V3KE.json" ;;
  Draft)    PROC_FILE="0.24mm Draft @Creality Ender3V3KE.json" ;;
  *) echo "process must be Fine|Optimal|Standard|Draft" >&2; exit 1 ;;
esac

# Filament lives in two places: Creality's own folder for the generics, and
# Orca's vendor library for branded spools. Resolve friendly names to either,
# then fall back to searching the library by name.
LIB="$(dirname "$SYS")/OrcaFilamentLibrary/filament"
case "$(echo "$FILAMENT" | tr '[:upper:]' '[:lower:]')" in
  polyterra)       FILAMENT_JSON="$LIB/Polymaker/PolyTerra PLA @System.json" ;;
  polyterra-dual)  FILAMENT_JSON="$LIB/Polymaker/PolyTerra Dual PLA @System.json" ;;
  polylite)        FILAMENT_JSON="$LIB/Polymaker/PolyLite PLA @System.json" ;;
  polylite-petg)   FILAMENT_JSON="$LIB/Polymaker/PolyLite PETG @System.json" ;;
  pla|petg|abs|tpu)
    F_UP="$(echo "$FILAMENT" | tr '[:lower:]' '[:upper:]')"
    FILAMENT_JSON="$SYS/filament/Creality Generic ${F_UP} @Ender-3V3-all.json" ;;
  *)
    # anything else: search the vendor library for a @System profile by name
    FILAMENT_JSON="$(find "$LIB" -iname "${FILAMENT}*@System.json" -print -quit 2>/dev/null)"
    [[ -n "$FILAMENT_JSON" ]] || { echo "unknown filament: $FILAMENT" >&2; exit 1; } ;;
esac

MACHINE="$SYS/machine/Creality Ender-3 V3 KE ${NOZZLE} nozzle.json"
PROCESS_JSON="$SYS/process/$PROC_FILE"

for f in "$MACHINE" "$PROCESS_JSON" "$FILAMENT_JSON"; do
  [[ -f "$f" ]] || { echo "missing profile: $f" >&2; exit 1; }
done

NAME="$(basename "${INPUT%.*}")"
# Build artifacts live beside the source, one folder per project - matching
# how the .stl files in this repo are already laid out.
[[ -n "$OUTDIR" ]] || OUTDIR="$(dirname "$INPUT")"
mkdir -p "$OUTDIR"
# --export-3mf silently fails on relative paths. Always absolute.
ABS_OUT="$(cd "$OUTDIR" && pwd)"
STL="$ABS_OUT/$NAME.stl"
PROJECT="$ABS_OUT/$NAME.3mf"

if [[ "$INPUT" == *.scad ]]; then
  echo "==> rendering $INPUT"
  "$OPENSCAD" "${SCAD_DEFS[@]+"${SCAD_DEFS[@]}"}" -o "$STL" "$INPUT"
else
  cp "$INPUT" "$STL"
fi

echo "==> building project  (${NOZZLE}mm nozzle · $PROCESS · $(basename "${FILAMENT_JSON%.json}"))"
"$ORCA" \
  --load-settings "$MACHINE;$PROCESS_JSON" \
  --load-filaments "$FILAMENT_JSON" \
  --export-3mf "$PROJECT" \
  "$STL" >/dev/null 2>&1 || true

# The CLI reports success unreliably; trust the artifact, not the exit code.
[[ -f "$PROJECT" ]] || { echo "FAILED: no project written" >&2; exit 1; }

echo "==> $PROJECT  ($(du -h "$PROJECT" | cut -f1))"
echo
echo "Open it in OrcaSlicer, slice, check the preview, then Print."
