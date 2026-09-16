# Stock Klipper config — Ender-3 V3 KE

Pulled off the Nebula Pad over Moonraker on **2026-09-16**, immediately after
rooting and before any config was modified. This is the factory Creality
configuration as shipped on firmware **1.1.0.17** (compiled 2025-07-29).

Retrieved with:

```bash
curl -s "http://192.168.1.65:7125/server/files/config/printer.cfg"
```

Live location on the printer: `/usr/data/printer_data/config/`

## Why this is kept

The documented rollback for this printer is a stock firmware `.img` on a USB
stick — and unlike the K1 series, there is no low-level recovery guide for the
Ender-3 series if that fails. This snapshot is the config-layer save point:
it will not reflash firmware, but it restores the printer's tuning and
machine definition if a config edit goes wrong.

## What is in here

`printer.cfg` includes three Creality-fork-only sections with **no mainline
Klipper equivalent**:

- `[prtouch_v2]` — load-cell automatic Z-offset (ships a compiled `.so` blob)
- `[z_compensate]`
- `[bl24c16f]` — EEPROM

Alongside them, `[bltouch]` is the CR-Touch doing bed mesh. Both probe systems
are present and do different jobs.

`[mcu rpi]` + `[adxl345]` put the input-shaper accelerometer on the Pad itself,
so it needs rewiring if the printer is ever moved to a Raspberry Pi host.

Together these are why moving to mainline Klipper on a Pi would lose automatic
Z-offset. See `~/tasks/switch-ke-off-creality-firmware.md`.
