# Portrait asset slots

Drop-in artwork for the two combatants. `portrait_frame.gd` already supports
texture replacement — set the exported `portrait_texture` (or add an
`ext_resource` in `Combat.tscn` and assign it) and the code-drawn silhouette
automatically stands down.

## Expected files

| File                  | Slot   | Notes                                   |
| --------------------- | ------ | --------------------------------------- |
| `undersigned.png`     | Enemy  | contract-themed, ominous, elegant       |
| `protagonist.png`     | Player | gothic protagonist, sharp silhouette    |

## Framing

- Bust / upper-body, face readable, centered on the frame
- Dark background (or transparent) — the portrait panel supplies the abyss
- Crimson rim light for the enemy, violet for the player
- Compose for display at ~280×250 (enemy) and ~250×220 (player) at 1280×720

## Palette discipline

Near-black `#0c0b10`, burgundy `#8c1d3d`/`#5c1630`, crimson `#dd3561`,
muted violet `#6d4bb4`, warm ivory `#f0eff2`. No colors outside this family.
