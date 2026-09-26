# VELVET//RUIN

A deckbuilding card battler built with Godot 4.

## Requirements

- Godot 4.7 (stable) or any newer Godot 4.x

## Getting started

1. Open the project folder in Godot (import `project.godot`).
2. Press **F5** (or the ▶ button) to run the main scene.
3. From the title screen, press **ENTER THE CONTRACT** to enter combat.

## Project layout

| Path       | Purpose                        |
| ---------- | ------------------------------ |
| `scenes/`  | Game scenes (`.tscn`)          |
| `scripts/` | GDScript code (`.gd`)          |
| `data/`    | Card and combat data           |
| `assets/`  | Art, audio, and fonts          |
| `ui/`      | UI theme and related resources |

## Status

Milestone 1E complete — combat composition pass. Three-zone battlefield: enemy
(intent tag, name, HP) on top, deliberate stage space with restrained ornament
in the center, and a bottom band anchoring the player portrait beside the hand,
energy, piles and End Turn. Larger combatant portraits, per-kind gothic card
sigils filling the art wells with solid value plaques, and HUD chips attached to
each combatant. 24/24 playtest and 42/42 rules harness still pass; no gameplay
rules touched. No map, shops, relics, statuses, or run progression yet.

1E corrective pass: explicit safe margins (16/12/16/14) around the whole
composition, player state chip restacked under the portrait (HP bar full width,
no left clipping), portrait halo clamped inside its bounds (no intent-chip
overlap), tightened vertical gap, and a playtest safe-area assertion for every
combat element. Screenshots: run
`Godot . --resolution 1280x720 --script res://scripts/screenshot_combat.gd`
which writes `.tools/screenshot_combat_720.png`.

1F: first asset integration. Five palette-locked SVG card illustrations
(original, hand-authored vector art in `assets/cards/`) render inside the card
art wells via a texture seam with the code-drawn sigil as automatic fallback.
Portrait slots (`assets/portraits/undersigned.png` / `protagonist.png`) drop in
without code changes; the silhouette fallback remains.

1G: visual direction reset — characters, battlefield, cards. Portraits are
restrained rectangular panels (hairline frame, accent corner ticks, crimson for
the enemy / violet for the player) instead of circular dials; the code-drawn
bust remains only as fallback until real PNGs arrive. The center battlefield is
negative space: a soft horizon band, one thin divider, a few ember marks. Cards
lead with artwork — cost + name over a large illustration, one hairline, then
value and description. Primary reads (HP, block, energy, intent, End Turn) sit
tight to their combatants or the hand; pile counts are quiet. 24/24 playtest
checks and 42/42 rules harness pass at a real 1280x720 window; combat_state.gd
untouched.
