# ART_INTAKE_AUDIT.md

**Scope:** read-only intake audit of four extracted asset packs.
**Audit date:** 2026-09-26
**Source root:** `C:\Users\User\VELVET_RUIN_ASSETS`
**Project root:** `C:\Users\User\velvet-ruin`

> **Nothing was imported, copied, converted, or modified to produce this document.**
> This audit reads the asset packs and the existing project only. No file under
> `assets/` was added or changed, no scene was edited, and no script was touched.
> `scripts/combat_state.gd` is unmodified. The UI is unmodified.

All source paths below are given relative to the source root
`C:\Users\User\VELVET_RUIN_ASSETS\`.

---

## 0. Method and exclusions

- Inspected the real files on disk: 595 files, 20.29 MB, 4 packs.
- Excluded from consideration, as instructed:
  - `GothicVania Town/__MACOSX/**` (entire AppleDouble mirror tree)
  - all `._*` AppleDouble stubs (35 such files)
  - all `.DS_Store` (4)
  - all previews / demo scenes / engine scaffolding
  - byte-identical duplicates (see §5)
- Verified PNG dimensions and colour type from the IHDR chunk of every image,
  rather than trusting filenames.
- Verified licences from the shipped documentation, PDF metadata, and in-file
  strings. Where a licence could not be established, that is recorded as a
  finding rather than assumed.

### PNG colour types used below
| Code | Meaning |
| ---- | ------- |
| `ct=2` | RGB, **no alpha** |
| `ct=3` | indexed/palette |
| `ct=6` | RGBA, **with alpha** |

---

## 1. The direction gate

VELVET//RUIN is a gothic, anime-influenced indie card battler. Assets must serve
this target and nothing else:

| Token | Value | Meaning in practice |
| ----- | ----- | ------------------- |
| Near-black | `#0c0b10` | the default state of the screen, not a background colour |
| Deep burgundy / crimson | `#8c1d3d` `#5c1630` `#dd3561` | enemy accent, heat, damage |
| Muted violet | `#6d4bb4` | player accent, intent, corruption |
| Warm ivory | `#f0eff2` | the only permitted highlight |
| Restrained gilt | — | used sparingly; never as a large fill |
| Elegant / sharp shapes | — | hairlines, tapered points, no chunky borders |
| Subtle corruption / glitch | — | occasional, small, never decorative noise |

Additional hard constraints taken from the existing codebase:

- Render target is **1280x720, `gl_compatibility`**, not a pixel-art renderer.
- All shipped art is **hand-authored SVG vector** (`assets/cards/*.svg`, 256x180),
  rendered at native resolution with no texture filtering concerns.
- The UI is **entirely code-drawn**: `ui/velvet_theme.tres` is built from
  `StyleBoxFlat` sub-resources with 1px borders and 2–4px corner radii.
  `PortraitFrame._draw()` and `StageOrnament._draw()` draw hairlines, ticks and
  ember dots procedurally.
- Typography is a `SystemFont` serif stack (`Georgia`/`Palatino Linotype`), 16px
  base, not a bitmap font.

**The single most important consequence:** this project is currently a
*vector, hairline, near-black* presentation. Every pack on offer is *chunky
16-bit pixel art*. The two are not stylistically adjacent, and a 16px pixel
tileset or a 24px-tall pixel 9-slice dropped into a 1280x720 vector UI will read
as a foreign object, not as an asset. This governs most of the verdicts below.

---

## 2. Current state snapshot

### Git
```
branch:  main
HEAD:    624686f "Initial commit"  (only commit)
status:   M README.md
          ?? .gitignore
          ?? assets/
          ?? project.godot
          ?? scenes/
          ?? scripts/
          ?? ui/
```
The working tree is essentially uncommitted: the entire game exists only as
untracked files plus a modified `README.md`. **There is no clean baseline to
diff art changes against.** Any import should land with the existing tree
committed first, so asset changes are reviewable in isolation.

### Project structure
```
velvet-ruin/
  project.godot            Godot 4.7, 1280x720, gl_compatibility, main=Main.tscn
  README.md                milestone log through 1G
  data/                    EMPTY
  assets/
    cards/                 5 x .svg   (hand-authored vector card illustrations)
    portraits/             .gitkeep + README.md  (drop-in slot, no art yet)
  scenes/                  Combat.tscn, Main.tscn
  scripts/                 14 .gd
  ui/
    velvet_theme.tres      Theme, 21 sub-resources, StyleBoxFlat only
    fonts/gothic_serif.tres  SystemFont serif stack
  .tools/                  gitignored local Godot 4.7.2 + screenshot harness
```

### Existing combat implementation (read only, not modified)
- `scripts/combat_state.gd` — `RefCounted` single source of truth. One enemy,
  5-card hand, 3 energy, deterministic under seed. Not touched by this audit.
- `scripts/combat_ui.gd` — `Control` presentation layer. Reads `CombatState`,
  writes labels, runs the turn sequence. Not touched.
- `scripts/card_view.gd` — builds cards entirely in code. Has an **art seam**:
  `const CARD_ART` maps card kind -> `res://assets/cards/*.svg`, with
  `CardSigil` (code-drawn) as automatic fallback.
- `scripts/portrait_frame.gd` — has a **texture seam**: exported
  `portrait_texture`; code-drawn silhouette stands down when set.
- `scripts/combat_ui.gd` `PORTRAIT_TEXTURES` — expects
  `res://assets/portraits/undersigned.png` and `.../protagonist.png`, resolved
  via `ResourceLoader.exists()`, silent if absent. Neither file exists yet.

**This matters for the audit:** the project has two clean, already-wired seams
where art drops in without code changes (`CARD_ART` and `portrait_texture`),
and **no** pack in this intake provides art that fits either one. Both seams are
waiting on bespoke, palette-locked art, not on pack assets.

### Direction notes from existing art
`assets/cards/velvet_cut.svg` is the reference standard, and states its own
palette in a comment: bg `#0e0d12`, velvet `#4a1224`/`#380d1b`/`#5c1630`,
cut `#f0eff2`, crimson `#dd3561`. Layered drapery, one clean diagonal, one
sparse spark. Restrained by construction. Any candidate asset should be
measured against this, and it is the reason all four packs underperform.

---

## 3. Pack-by-pack audit

### 3.1 `Dark Dwellers GUI`

**What it is:** "Tiny RPG - Dark Dwellers" — a pixel-art *RPG character stat
screen* kit. 92 PNGs plus one `README.html`. Every file is a 9-slice panel part,
a button state sheet, a tab, a bar, a header, a cursor, a mouse pointer, or a
**piece-of-equipment frame**.

#### Useful
- The five 9-slice panel sheets (`20251029darkDwellers9SlicesA–E.png`, 96x96).
  These are the only general-purpose pieces in the pack.
- `20251125portraitFrameA.png` (66x72) — decorative frame construction reference.
- `20251125compass.png` (79x82) — a plausible ornament/glyph.

None of these can be dropped into the current UI. They are chunky 24–32px pixel
borders; the live theme is 1px `StyleBoxFlat` hairlines with 2–4px radii. Their
value is as **construction reference** for a future pixel-styled sub-screen
(map / relics), not as combat chrome.

#### Should be ignored
- **All 12 equipment frames** (weapon, ring, chest, neck, boots, helmet, pants,
  shield × A/B/C). These belong to an RPG inventory screen. VELVET//RUIN has no
  equipment system, and adding one is out of scope.
- **All buttons** (`darkDwellersButtonA1–E1-Sheet.png`, plus close / help /
  options / exit / up / down / left / right / more / less). The existing theme
  already styles buttons correctly.
- **All tabs** (`darkDwellersTabA1–J1-Sheet.png`). No tabbed UI exists.
- **All bars** (`darkDwellersBarA–L.png`). HP/block bars are code-drawn.
- **All headers** (`darkDwellersHeaderA–E.png`).
- **All cursors** (`darkDwellersCursourA/B1-Sheet.png`,
  `darkDwellersHorizontal/VerticalCursourA–D1-Sheet.png`) and **mouse
  pointers** (`mouseSmall1-Sheet.png`, `mouseBig1-Sheet.png`). The project uses
  the default system cursor; custom cursors are not in the visual brief.
- Remaining portrait frames `B–F`, and `emptyFrameA–C1-Sheet.png`.

#### License / provenance
Clean and unambiguous.
- Source: <https://tiopalada.itch.io/tiny-rpg---dark-dwellers-gui>
- Author: Gabriel "tiopalada" Lima
- Licence: **CC0 1.0 Universal** (public domain dedication), stated verbatim in
  `Dark Dwellers GUI/README.html`.
- No attribution required. No restrictions. No attribution debt.

#### Exact paths for useful assets
```
Dark Dwellers GUI/20251029darkDwellers9SlicesA.png   96x96  ct=6
Dark Dwellers GUI/20251029darkDwellers9SlicesB.png   96x96  ct=6
Dark Dwellers GUI/20251029darkDwellers9SlicesC.png   96x96  ct=6
Dark Dwellers GUI/20251029darkDwellers9SlicesD.png   96x96  ct=6
Dark Dwellers GUI/20251029darkDwellers9SlicesE.png   96x96  ct=6
Dark Dwellers GUI/20251125portraitFrameA.png         66x72  ct=6
Dark Dwellers GUI/20251125compass.png                79x82  ct=6
```

#### Classification
| Asset | Verdict | Reason |
| ----- | ------- | ------ |
| 9Slices A–E (5) | **MAYBE** | reference-only; chunky pixel 9-slice, wrong register for combat UI |
| `portraitFrameA` | **MAYBE** | frame construction reference; live portrait frame is already better |
| `compass.png` | **MAYBE** | possible ornament; unproven in situ |
| 9Slices — remaining shapes | IGNORE | — |
| Equipment frames ×12 | IGNORE | RPG stat screen; no equipment system |
| Buttons / tabs / bars / headers | IGNORE | already handled by `velvet_theme.tres` |
| Cursors / mouse pointers | IGNORE | not in visual brief |
| Portrait frames B–F | IGNORE | superseded by code-drawn frame |

**KEEP count: 0.** This pack is licence-clean but stylistically wrong. It earns
a place in the repo only as reference material, and only if a pixel-styled
non-combat sub-screen is ever built.

---

### 3.2 `Generic Dark Pixel UI`

**What it is:** a complete Godot 4 `Theme` plus its source atlases, 72 `.tres`
style resources, Aseprite sources, and a demo scene. A UI kit, not art for a
game.

#### Useful
Very little, and nothing that survives the direction gate.

The pack's one genuinely interesting component is
`GuiAssets/gdp_icons.png` (256x256) — a sprite atlas including a
`skull_bones_shaded` glyph. A skull is on-theme. But it is a 16px shaded pixel
icon from a generic dark UI set, alongside `email`, `folder_open`, `clock`,
`sound_high` and `cross`. Adopting the atlas means adopting the whole icon
language; cherry-picking one glyph out of a sheet requires hand-slicing, which
is authoring work, not intake.

The pack's `fonts/TinyPixie2.ttf` **is** useful — but it is a byte-identical
duplicate of the file in the NB Pixel Font Bundle, and it is not even the right
face for this project (see §3.4). Use the NB copy; ignore this one.

#### Should be ignored
- `GuiAssets/gdp_theme.tres` — **6.4 MB.** A complete `Theme` that would replace
  `ui/velvet_theme.tres` wholesale. Adopting it *is* a UI redesign, which is
  explicitly out of scope, and it would discard the entire established look.
- All 72 `.tres` resources under `styles/` and `icons/` — they reference the
  two atlases by absolute path and only work as part of the discarded theme.
- `gdp_styles.png` (256x256) and `gdp_icons.png` (256x256) — the theme's private
  atlases.
- `sample_assets/gui_sample.tscn` (22 KB) — demo scene.
- `sample_assets/*.gd` (`gui_sample.gd`, `IconContainer.gd`, `fill_tree.gd`,
  `ProgressBar.gd`) and `button_group.tres` — demo scaffolding.
- `texture_buttons/tb_plus.tscn`, `tb_minus.tscn` — demo widgets.
- `sprites/*.aseprite` (4 files) — authoring sources.
- `fonts/TinyPixie2.ttf.import` — a Godot import stub (see §6).
- `fonts/_README.md` — a copy of the NB Pixel Font Bundle readme (see §5).

#### License / provenance
Licence is **CC0 1.0**, but it is documented in the *worst possible place* —
buried inside the demo scene's popup panel, not in any top-level licence file:

- `GuiAssets/sample_assets/gui_sample.tscn` contains the strings
  `"Licence:"`, `"Creative Commons Zero v1.0 Universal"`,
  `"Created By: https://hoonius.itch.io/"`, and
  `"HomePage: https://hoonius.itch.io/generic-dark-pixel-ui"`.
- Author: **hoonius** — <https://hoonius.itch.io/generic-dark-pixel-ui>
- There is **no** `LICENSE`, `README.md`, or `CREDITS` file at the pack root.
  `GuiAssets/faq.txt` contains only Godot display/filtering advice and no
  licensing information at all.

**Provenance finding:** the licence was recovered by grepping a demo scene, not
by reading documentation. It is recorded here so the fact is not lost, and it
should be re-confirmed against the live itch.io page before this pack is ever
relied upon. `gui_sample.tscn:716` is the citation.

#### Exact paths for useful assets
```
Generic Dark Pixel UI/GuiAssets/sprites/gdp_icons.png   256x256  ct=3  (skull glyph, MAYBE only)
Generic Dark Pixel UI/GuiAssets/fonts/TinyPixie2.ttf            (duplicate -> use NB copy)
```

#### Classification
| Asset | Verdict | Reason |
| ----- | ------- | ------ |
| `gdp_icons.png` | **MAYBE** | `skull_bones` glyph is on-theme; needs hand-slicing out of the atlas |
| `fonts/TinyPixie2.ttf` | IGNORE | byte-identical duplicate of the NB bundle file |
| `gdp_theme.tres` (6.4 MB) | IGNORE | adopting it is a UI redesign; out of scope |
| All `styles/**.tres`, `icons/**.tres` | IGNORE | bound to the discarded theme's atlases |
| `gdp_styles.png` | IGNORE | private atlas of the discarded theme |
| Demo scenes, demo `.gd`, texture buttons | IGNORE | scaffolding |
| `*.aseprite`, `*.import` | IGNORE | authoring sources / engine stubs |

**KEEP count: 0.**

---

### 3.3 `GothicVania Town`

**What it is:** "GothicVania Town" by **Luis Zuno (@ansimuz)** — a 16-bit
*daylit medieval village* scene: 2 parallax layers, a 16x16 tileset, 40 modular
sliced tiles, ~13 props, 4 animated townfolk NPCs, a title screen, a Phaser 3
demo, PSD sources, and two music tracks.

**This is the pack with the most assets and the worst palette fit.** It is a
bright, warm, cheerful village. Its pixel data confirms it: the tile art sits in
the mid-to-high value range with warm browns, greens and sky tones, the exact
opposite of a near-black burgundy screen. Nothing in it can be dropped in
unmodified.

There is, however, a real opportunity here, and it is the *only* pack that
offers any: the two parallax layers are **silhouette-and-sky landscape art**.
Desaturated and crushed toward near-black with a single crimson rim, a
rooftop-and-spire silhouette is legitimately on-direction, and is exactly the
"atmospheric material" a title screen or map backdrop wants. That is a recolor
job, not an import job — so these are MAYBE, not KEEP.

#### Useful
- `PNG/environment/layers/background.png` (384x288, `ct=2`, no alpha) — far
  parallax layer. The best recolor candidate in the entire intake.
- `PNG/environment/layers/middleground.png` (384x288, `ct=6`) — town silhouette
  layer, has alpha.
- `PNG/environment/props-sliced/street-lamp.png` (35x108) — a lamp post reads
  as gothic silhouette material.
- `PNG/environment/props-sliced/chuch.png` (367x263, 23 KB) — the church. The
  single most gothic object in any of the four packs (note the filename typo,
  `chuch`, is in the original).
- `PNG/environment/props-sliced/well.png` (65x65) — small, neutral, reusable.

#### Should be ignored
- **All 4 NPCs — 4 characters x (idle + walk) = 60 individual frames, plus 8
  spritesheets.** `woman-*`, `bearded-*`, `hat-man-*`, `oldman-*`. These are
  cheerful daylight villagers. They are **not** the protagonist, they are
  **not** THE UNDERSIGNED, and they do not "genuinely fit" by any reading of the
  brief. Per the explicit instruction, pack characters are not to be used as
  primary character art unless they genuinely fit. They do not. See §4.1.
- `PNG/environment/layers/tileset.png` (592x192) and all 40 files in
  `PNG/environment/layers/sliced-tileset/`. A 16x16 tileset implies a tilemap.
  VELVET//RUIN is a card battler with a three-zone 1280x720 vector battlefield
  and no tilemap. Adopting a tileset is a commitment to a 16-bit side-scroller
  rendering style the project does not have and the brief does not want.
- `PNG/environment/props-sliced/house-a/b/c.png`, `crate.png`, `crate-stack.png`,
  `barrel.png`, `sign.png`, `wagon.png` — village set dressing. Coherent as a
  village, irrelevant to contracts and debt.
- `PNG/environment/props/houses.png` (1126x272), `props.png` (352x192) — the
  unsliced originals of the above.
- **All previews** (per instructions): `environment-preview.png` (1536x288),
  `church-preview.png` (384x288), `church-preview-big.png` (768x576).
- **All title-screen files**: `title-screen.png`, `press-enter-text.png`,
  `credits-text.png`, `instructions.png`. These are the *original pack's* logo
  and menu furniture, branded to it. Using them would be shipping someone
  else's title screen.
- **All GIFs** (8) — demo playback loops.
- **All PSDs** (11, incl. a 1.2 MB `environment.psd` and 1.26 MB `concepts.psd`)
  — authoring sources.
- **All Phaser demo code**: `game.js`, `phaser.min.js` (809 KB), `index.html`,
  `atlas.json`, `atlas-props.json`, `map.json`, `atlas.tps`, `atlas-props.tps`,
  `atlas.png`, `atlas-props.png`, `loading.png`, and the entire `.idea/`
  JetBrains folder.
- **All music** (`Music/rpg_village02_loop.mp3`, `rpg_village02__loop.ogg`,
  plus the copies under `code/phaser-code/assets/sounds/`) — wrong mood *and*
  the only asset in this pack with an **attribution obligation**. See below.
- `public-license.pdf`, `looking-for-more.pdf` — the licence PDF (keep as
  provenance reference, do not ship) and a promotional catalogue PDF.

#### License / provenance
Two different licences apply inside this one pack. They must not be conflated.

**A. Artwork — CC0 1.0, no obligation.**
- Author: **Luis Zuno**, aka **@ansimuz** — <https://ansimuz.itch.io>
- Licence: **CC0 1.0 Universal** (public domain). Published on OpenGameArt as
  <https://opengameart.org/content/gothicvania-town>, which records
  `License(s): CC0` and carries Zuno's own notice:
  > "Artwork created by Luis Zuno @ansimuz — License for Everyone. Public domain
  > and free to use on whatever you want, personal or commercial. Credit is not
  > required but appreciated."
- In-pack corroboration: `GothicVania-town-files/public-license.pdf`. PDF
  metadata confirms `/Author (Luis Zuno)`, `/Producer (Canva)`,
  `/CreationDate (D:20240903013736+00'00')`, `/Lang (es-419)`, 2 pages.
  The body text is CID-encoded with no usable `ToUnicode` CMap, so it could not
  be machine-extracted; the metadata and the matching OpenGameArt record are
  the evidence used. (See §7.)
- No attribution required. Safe for commercial release.

**IMPORTANT — do not generalise this licence to the other GothicVania packs.**
Zuno's *paid* itch.io releases (Gothicvania Interiors, Bridge Art Pack, Gothicvania
Collection) carry a materially different, **non-CC0** licence: "You may use these
assets in personal or commercial projects. You may modify these assets to suit
your needs. You **can NOT re-distribute the file**, no matter how much you modify
it." The CC0 status documented above is specific to the older free
**GothicVania Town** release that is actually in this folder. Do not bulk-import
from Zuno's paid packs on the strength of this finding.

**B. Music — attribution required, NOT CC0.**
- Composer: **Pascal Belisle** (aka "pacethemusician" / thetoadz)
  — <https://soundcloud.com/pascalbelisle>
- Terms, from `GothicVania-town-files/Music/readme.txt`:
  > "You are free to use the music in your projects as long as you give
  > appropriate credit."
- This creates a **credit obligation**. VELVET//RUIN currently has no credits
  screen. The music is also a bright pastoral village loop, tonally wrong for
  the brief. **Recommendation: do not use.** Recorded here so the obligation is
  never discovered late.

#### Exact paths for useful assets
```
GothicVania Town/GothicVania-town-files/PNG/environment/layers/background.png      384x288  ct=2
GothicVania Town/GothicVania-town-files/PNG/environment/layers/middleground.png   384x288  ct=6
GothicVania Town/GothicVania-town-files/PNG/environment/props-sliced/street-lamp.png  35x108  ct=6
GothicVania Town/GothicVania-town-files/PNG/environment/props-sliced/chuch.png        367x263  ct=6
GothicVania Town/GothicVania-town-files/PNG/environment/props-sliced/well.png          65x65  ct=6
```

#### Classification
| Asset | Verdict | Reason |
| ----- | ------- | ------ |
| `background.png` | **MAYBE** | best recolor candidate in the intake; needs full desaturate + crush to near-black |
| `middleground.png` | **MAYBE** | same; has alpha, suits a silhouette layer |
| `street-lamp.png` | **MAYBE** | gothic silhouette prop; needs recolor |
| `chuch.png` (church) | **MAYBE** | most gothic object available; needs recolor |
| `well.png` | **MAYBE** | neutral, reusable; needs recolor |
| All 4 NPCs (60 frames + 8 sheets) | IGNORE | cheerful daylight villagers; not our characters |
| `tileset.png` + 40 sliced tiles | IGNORE | implies a tilemap the game does not have |
| Village props / houses | IGNORE | village set dressing, wrong subject |
| All previews | IGNORE | previews |
| All title-screen files | IGNORE | original pack's branding |
| GIFs / PSDs / Phaser code / `.idea` | IGNORE | demos, sources, engine files |
| Music (mp3/ogg) | IGNORE | wrong mood + attribution obligation |

**KEEP count: 0 as-shipped.** Five MAYBE items, all requiring recolour before
they could ever be used.

---

### 3.4 `NB Pixel Font Bundle`

**What it is:** 20 pixel fonts (16px base; `TinyPixie2` is 12px) plus
`overview.png`. The cleanest licence in the intake.

#### Useful
Filtered against "elegant / sharp / gothic / restrained", five faces survive:

| File | Size | Register | Why it survives |
| ---- | ---- | -------- | --------------- |
| `Unknown.ttf` | 13,636 | gothic / old-style | The most on-tone face in the bundle. Reads as engraved and slightly ominous. Best candidate for the corruption-adjacent register. |
| `CelticTime.ttf` | 10,976 | medieval, inscriptional | Suits a contract, seal, or ledger motif. Narrow enough to stay quiet. |
| `Tallpix.ttf` | 9,888 | tall, condensed | Elegant by proportion alone. Good for tight columns and overlines where a wide face would crowd. |
| `LCDBlock.ttf` | 32,452 | digital / segmented | The one face that speaks to *subtle corruption / glitch* without literal noise. |
| `Zicons.ttf` | 31,456 | **icon font, not text** | A glyph sheet. Potentially useful for status and intent chips, which are currently text. |

#### Should be ignored
Fifteen faces whose register is retro, cartoony, or quirky — they would pull the
UI toward a cheerful 16-bit game rather than a gothic one:

`AtariGames.ttf`, `Awexbmp.ttf`, `BasicChineseLine.ttf`, `Beanstalk.ttf`,
`Bitfantasy.ttf`, `Habbo.ttf`, `KarenFat.ttf`, `Kubasta.ttf`, `MMXSNES.ttf`,
`Rockboxcond12.ttf`, `SandyForest.ttf`, `SquareSounds.ttf`, `TinyPixie2.ttf`,
`TripleN.ttf`, `Unknown.ttf` is kept — so the ignore list is the remaining
fourteen plus `overview.png`.

`TinyUnicode.ttf` is **MAYBE**: broad glyph coverage makes it a plausible
fallback for the box-drawing and separator characters used throughout
`combat_state.gd`, but it is a pixel face and the live UI is serif, so its value
is speculative.

#### License / provenance
The strongest provenance in the intake, and the only pack with an explicit
grant covering *redistribution* — which matters, because fonts get shipped.
- Bundle: **Nb Pixel Font Bundle**, Nimble Beasts Collective
  — <https://nimblebeastscollective.itch.io/nb-pixel-font-bundle>
- Verbatim from `_README.md`:
  > "This bundle contains 20 public domain fonts which you can use, modify,
  > distribute in personal and commercial projects without attribution."
- Described as the spiritual successor to the *magos free pixel font bundle*.
- Per-face authorship is itemised in the readme (e.g. `Unknown by Anonymous`,
  `CelticTime by LunarRay`, `Tallpix by TommyV`, `LCDBlock by vacuumfan7072`,
  `Zicons by Glyn`), and is reproduced in §7 for the record.
- **No attribution required, redistribution permitted.** Cleanest of the four.

#### Exact paths for useful assets
```
NB Pixel Font Bundle/Unknown.ttf       13,636 bytes
NB Pixel Font Bundle/CelticTime.ttf    10,976 bytes
NB Pixel Font Bundle/Tallpix.ttf        9,888 bytes
NB Pixel Font Bundle/LCDBlock.ttf      32,452 bytes
NB Pixel Font Bundle/Zicons.ttf        31,456 bytes
NB Pixel Font Bundle/TinyUnicode.ttf   23,136 bytes   (MAYBE)
```

#### Classification
| Font | Verdict | Reason |
| ---- | ------- | ------ |
| `Unknown.ttf` | **KEEP** | most on-tone face; gothic/old-style |
| `CelticTime.ttf` | **KEEP** | suits contract/seal motif |
| `Tallpix.ttf` | **KEEP** | elegant proportions |
| `LCDBlock.ttf` | **KEEP** | serves the corruption/glitch register |
| `Zicons.ttf` | **KEEP** | icon font; useful for status/intent chips |
| `TinyUnicode.ttf` | MAYBE | speculative glyph-fallback value |
| 14 other faces | IGNORE | retro/cartoon/quirky register |
| `overview.png` | IGNORE | specimen sheet, not a game asset |

**KEEP count: 5.**

**Critical constraint on this KEEP:** importing these fonts is a *capability*,
not a typographic change. `ui/velvet_theme.tres` must keep pointing at
`ui/fonts/gothic_serif.tres` (the `SystemFont` serif stack) and the live UI must
not be restyled. A pixel face and the existing 16px serif UI do not coexist in
one screen. These files land in the repo as available, individually adoptable
options for a *future* deliberate type decision — nothing changes on screen.

---

## 4. Category audit

### 4.1 Character assets
**Verdict: nothing in this intake is usable as VELVET//RUIN character art.**

Four characters exist across the packs:
- GothicVania Town `woman` / `bearded` / `hat-man` / `oldman` — 60 frames +
  8 spritesheets, 34x42 to 39x52 px each.
- Dark Dwellers ships **no characters at all** — only equipment *frames*.
- Generic Dark Pixel UI ships **no characters** — generic utility icons only.

The GothicVania NPCs are small, low-detail, brightly lit daylight villagers
with walk cycles. Recasting one as a gothic protagonist would mean repainting
the sprite, reshooting the animation, and re-establishing silhouette — at which
point it is bespoke art that happens to have begun life as a pack asset. The
audit's job is to say plainly that this trade is not worth making.

`assets/portraits/README.md` already specifies what is actually needed:
~280x250 enemy / ~250x220 player bust crops, dark or transparent ground,
crimson rim for the enemy and violet for the player, palette-locked to
`#0c0b10` `#8c1d3d` `#5c1630` `#dd3561` `#6d4bb4` `#f0eff2`. No asset in any
pack meets this, and the `portrait_texture` seam is correctly waiting on
bespoke work.

**No pack character is recommended for import.**

### 4.2 Card assets
**Verdict: nothing in this intake is usable. The existing SVGs stay.**

VELVET//RUIN's card art is five hand-authored 256x180 SVGs in
`assets/cards/`, palette-locked with the palette stated in-file, wired through
`CardView.CARD_ART`. They are the visual reference standard for the project.

The packs contain no card frames, no card art, and nothing card-shaped.
Dark Dwellers' equipment frames are the nearest relatives by function, and they
are RPG-inventory furniture, not cards.

Pixel-art card illustration at 16x16 source resolution cannot be scaled to fill
a large art well in a 1280x720 vector card without visible pixel magnification
against smooth vector chrome.

**`CARD_ART` is not to be repointed. The five SVGs are not to be replaced.**

### 4.3 Map / environment assets
**Verdict: one MAYBE cluster; the tilesets are a hard IGNORE.**

`background.png` + `middleground.png` (and the church / lamp / well) are the
only plausible atmospheric source material, and all require a full recolour to
near-black before use. See §3.3.

The 16x16 tileset and its 40 sliced modular tiles imply a tilemap renderer. The
battlefield is three code-drawn zones (`StageOrnament` — a horizon band, one
divider, five ember dots) on a flat clear colour
`Color(0.0392157, 0.0313726, 0.0431373)`. A tilemap is not part of this project
and would be a rendering-style commitment, not an asset intake.

### 4.4 UI assets
**Verdict: IGNORE all of it. The existing theme is correct.**

`ui/velvet_theme.tres` is a coherent, purpose-built 21-sub-resource theme:
1px borders, 2–4px corner radii, a disciplined five-colour set, `VELVET` crimson
and violet accents, and a matching ProgressBar pair. The whole live UI is
code-drawn, including portrait frames and stage ornament.

Both UI packs offer replacements, and both replacements are strictly worse:
- `gdp_theme.tres` (6.4 MB) is a full theme swap — a UI redesign, out of scope.
- Dark Dwellers' pieces are chunky 24–32px pixel 9-slices for an RPG stat screen.
- Generic Dark Pixel UI's icon set is utility chrome (email, folder, clock,
  sound, lock) with no gothic register beyond a single skull.

No UI asset from any pack is recommended for import.

### 4.5 Fonts
**Verdict: 5 KEEP (the only real wins in this intake), 1 MAYBE, 14 IGNORE.**

See §3.4. The five KEEPs are licensed public domain, redistributable, and
individually adoptable. Importing them changes nothing on screen; wiring one in
is a separate, deliberate typographic decision for a later milestone.

The one face to watch is `Zicons.ttf` — an *icon* font. It is the only asset in
the entire intake that could serve the "subtle corruption / glitch" brief
directly, and the only one that could replace the text-based intent and status
readouts without inventing new art.

### 4.6 Backgrounds / textures
**Verdict: 2 MAYBE (`background.png`, `middleground.png`); nothing else.**

No pack ships a tileable surface texture, a grunge overlay, a vignette, a
noise/grain map, or a paper/parchment texture — i.e. none of the things that
would actually build the "near-black, corrupted, atmospheric" surface the brief
asks for. The atmospheric material simply is not in these packs.

`background.png` is `ct=2` (no alpha) and `middleground.png` is `ct=6`; both are
384x288, i.e. authored for a 4:3 side-scroller, not for a 16:9 1280x720 screen.
They would need upscaling and a horizontal re-composition even after recolour.

The "subtle corruption / glitch" treatment — scanline drift, channel offset,
block displacement, dithered decay — is **not present as an asset anywhere in
this intake**. It remains to be authored.

### 4.7 Atmospheric material
**Verdict: the weakest category. 5 MAYBE, 0 KEEP.**

Atmospheric material is the category these four packs were *least* able to
serve. What exists:

- GothicVania `background.png` / `middleground.png` — a daylight village
  panorama. Recolourable to a silhouette, which is the one real opportunity.
- GothicVania `chuch.png` (church), `street-lamp.png` — two genuinely gothic
  silhouettes, both needing recolour.
- Dark Dwellers — nothing atmospheric. It is UI furniture only.
- Generic Dark Pixel UI — nothing atmospheric. It is UI furniture only.
- Music: the only *audio* atmospheric material in the intake is Pascal Belisle's
  bright pastoral village loop, which carries an attribution obligation and is
  tonally wrong. Recommend not using it.

**Nothing in this intake should be expected to produce VELVET//RUIN's
atmosphere.** That atmosphere has to be authored — as vector/SVG work in the
established idiom of `assets/cards/*.svg`, or as procedural code in the idiom of
`StageOrnament` and `PortraitFrame`. The packs contribute raw material for a
recolour experiment at best.

---

## 5. Cross-pack findings

### 5.1 Byte-identical duplicates
Verified by SHA-256.

**Font duplication.** `Generic Dark Pixel UI/GuiAssets/fonts/TinyPixie2.ttf` is
byte-identical to `NB Pixel Font Bundle/TinyPixie2.ttf` (8,532 bytes, same hash).
The Generic Dark Pixel UI pack embeds a copy of the NB bundle and ships only
that one face. **Rule: take all fonts from the NB Pixel Font Bundle only.** The
Generic Dark Pixel UI copy is a duplicate and is IGNORE.

**Doc duplication.** `Generic Dark Pixel UI/GuiAssets/fonts/_README.md` is a
byte-for-byte copy of `NB Pixel Font Bundle/_README.md` (1,244 bytes each). The
NB copy is canonical.

**GothicVania internal duplication.** Seven PNGs each exist twice inside
`GothicVania Town/GothicVania-town-files/`, once under `PNG/` and once under
`code/phaser-code/assets/`, with identical hashes:
`background.png`, `middleground.png`, `tileset.png`, `title-screen.png`,
`press-enter-text.png`, `credits-text.png`, `instructions.png`.
**Rule: source everything from `PNG/`. Never from `code/phaser-code/assets/`.**

Sprite duplication: `PNG/spritesheets/*.png` (8 files) are horizontal strips
assembled from the individual frames in `PNG/sprites/<char>-<state>/*.png`.
Take individual frames or the sheet, never both.

Audio duplication: `Music/rpg_village02_loop.mp3` /
`rpg_village02__loop.ogg` are also present under
`code/phaser-code/assets/sounds/`. Moot — music is IGNORE on other grounds.

**`GothicVania Town/__MACOSX/` is a complete mirror of the entire pack**, with
its own `PNG/`, `PSD/`, `GIF/`, `Music/` and `code/` trees. It is 100% redundant
and must never be a source path. The same holds for all 35 `._*` AppleDouble
stubs and 4 `.DS_Store` files.

### 5.2 Licensing summary
| Pack | Author | Licence | Obligation |
| ---- | ------ | ------- | ---------- |
| Dark Dwellers GUI | Gabriel "tiopalada" Lima | **CC0 1.0** | none |
| Generic Dark Pixel UI | hoonius | **CC0 1.0** | none (documented only in a demo scene) |
| GothicVania Town — **art** | Luis Zuno (@ansimuz) | **CC0 1.0** | none |
| GothicVania Town — **music** | Pascal Belisle | custom, **attribution required** | credit in a credits screen |
| NB Pixel Font Bundle | Nimble Beasts Collective (20 authors) | **public domain** | none; redistribution permitted |

No pack in this intake carries a share-alike, non-commercial, or no-derivative
restriction on the assets recommended here. The only obligation anywhere is the
music credit, on the one item already recommended for rejection.

### 5.3 Engine files to ignore
Three Godot `.import` stubs ship inside `Generic Dark Pixel UI/GuiAssets/`:
`sprites/gdp_icons.png.import`, `sprites/gdp_styles.png.import`,
`fonts/TinyPixie2.ttf.import`. These are editor-generated import metadata, not
assets. Copying them into the project would import paths that do not resolve.
Also ignorable: `GothicVania Town/.../code/phaser-code/phaser.min.js` (809 KB),
`.idea/**`, `*.tps` (Aseprite tool settings).

---

## 6. Risk register

| # | Risk | Severity | Mitigation |
| - | ---- | -------- | ---------- |
| 1 | **No committed baseline.** Entire game is untracked; only commit is `624686f`. | High | Commit the current tree *before* any import, so art changes are reviewable in isolation. |
| 2 | **No `CREDITS` file exists.** Pascal Belisle's music requires attribution. | Medium | Do not use the music. If it is ever wanted, a credits screen is a prerequisite. |
| 3 | **Generic Dark Pixel UI licence is undocumented** outside a demo scene. | Medium | Re-confirm on itch.io before relying on it. Currently nothing is being imported from it, so exposure is zero. |
| 4 | **CC0 finding is pack-specific.** Zuno's *paid* Gothicvania packs are non-CC0 / no-redistribution. | Medium | Never bulk-import from Zuno's paid packs on the strength of the GothicVania Town finding. |
| 5 | **Pixel/vector register clash.** All four packs are 16-bit pixel art; the project is vector hairline UI. | High | The main reason 0 of ~350 candidate images are KEEP. Treat recolour as authoring, and budget it as such. |
| 6 | **Corruption/glitch treatment is absent** from every pack. | Medium | Must be authored. Not an intake gap that more shopping will close. |
| 7 | **Scale mismatch.** Pack art is authored for 4:3 side-scrollers (384x288); the game is 16:9 1280x720. | Medium | Any reuse needs recomposition, not just recolour. |
| 8 | **Pixel font vs. serif UI.** `Zicons`/`Unknown` etc. cannot coexist with the live `SystemFont` serif stack. | Low | Import as capability only. `velvet_theme.tres` must keep pointing at `gothic_serif.tres`. |
| 9 | **Filename typo in source.** `chuch.png` is the church. | Low | Preserve the original name in the audit trail; use a corrected name only at import time. |

---

## 7. Provenance appendix

### Pack 1 — Dark Dwellers GUI
- Title: Tiny RPG - Dark Dwellers
- Author: Gabriel "tiopalada" Lima — <https://tiopalada.itch.io/>
- Page: <https://tiopalada.itch.io/tiny-rpg---dark-dwellers-gui>
- Licence: **CC0 1.0 Universal**
- Evidence: `Dark Dwellers GUI/README.html`, single line, states the CC0
  dedication and links both the page and the author.

### Pack 2 — Generic Dark Pixel UI
- Title: Generic Dark Pixel UI
- Author: **hoonius** — <https://hoonius.itch.io/generic-dark-pixel-ui>
- Licence: **CC0 1.0 Universal**
- Evidence: `GuiAssets/sample_assets/gui_sample.tscn` — strings `"Licence:"`
  (line 683), `"Creative Commons Zero v1.0 Universal"` (line 716 region),
  `"Created By:"` + `https://hoonius.itch.io/`,
  `"HomePage:"` + `https://hoonius.itch.io/generic-dark-pixel-ui`.
- No top-level licence file exists.

### Pack 3 — GothicVania Town
- Title: GothicVania Town
- Art author: **Luis Zuno** (@ansimuz) — <https://ansimuz.itch.io>
- Art licence: **CC0 1.0** — <https://opengameart.org/content/gothicvania-town>
  (`License(s): CC0`; author's notice: *"License for Everyone. Public domain and
  free to use on whatever you want, personal or commercial. Credit is not
  required but appreciated."*)
- In-pack licence PDF: `GothicVania-town-files/public-license.pdf`
  - `/Title (public-license)`, `/Author (Luis Zuno)`, `/Creator (Canva)`,
    `/Producer (Canva)`, `/CreationDate (D:20240903013736+00'00')`,
    `/Lang (es-419)`, 2 pages, PDF 1.4.
  - Body text is CID-encoded with no usable `ToUnicode` CMap and could not be
    extracted programmatically. The PDF's own metadata plus the matching
    OpenGameArt record are the evidence relied on.
- Music author: **Pascal Belisle** — <https://soundcloud.com/pascalbelisle>
- Music licence (`GothicVania-town-files/Music/readme.txt`):
  *"You are free to use the music in your projects as long as you give
  appropriate credit."* — attribution required, not CC0.
- `looking-for-more.pdf` — promotional catalogue, same producer. No licence
  terms.

### Pack 4 — NB Pixel Font Bundle
- Title: Nb Pixel Font Bundle
- Publisher: Nimble Beasts Collective
  — <https://nimblebeastscollective.itch.io/nb-pixel-font-bundle>
- Licence: **public domain** — *"use, modify, distribute in personal and
  commercial projects without attribution."*
- Predecessor: magos free pixel font bundle
  — <https://nimblebeastscollective.itch.io/magosfonts>
- Evidence: `NB Pixel Font Bundle/_README.md`. All fonts are 16px base except
  `TinyPixie2` at 12px.
- Per-face authorship (as listed in the readme):
  `AtariGames` Kieran · `Awex bmp` Awex SPLBank · `BasicChineseLine` frizznickrz ·
  `Beanstalk` MistressEllipsis · `Bitfantasy` Mitch · `CelticTime` LunarRay ·
  `Habbo` Omni · `KarenFat` PaulSpades · `Kubasta` KaiKubasta ·
  `LCDBlock` vacuumfan7072 · `MMXSNES` Anonymous · `Rockboxcond12` frizznickrz ·
  `SandyForest` JayWright · `SquareSounds` iLKke · `Tallpix` TommyV ·
  `TinyPixie2` TinyPixie · `TinyUnicode` DuffsDevice · `TripleN` NyoNeoNao ·
  `Unknown` Anonymous · `Zicons` Glyn

---

## 8. FIRST IMPORT BATCH

**10 KEEP items.** All licence-clean, all additive, all changing nothing on
screen. Destination root: `assets/art/` (does not exist yet — it will be
created at import time, not by this audit).

Original filenames are preserved for provenance traceability.

### 8.1 Group A — Fonts (5)

| # | Source path (relative to `C:\Users\User\VELVET_RUIN_ASSETS\`) | Destination | Bytes |
| - | --- | --- | --- |
| 1 | `NB Pixel Font Bundle/Unknown.ttf` | `assets/art/fonts/Unknown.ttf` | 13,636 |
| 2 | `NB Pixel Font Bundle/CelticTime.ttf` | `assets/art/fonts/CelticTime.ttf` | 10,976 |
| 3 | `NB Pixel Font Bundle/Tallpix.ttf` | `assets/art/fonts/Tallpix.ttf` | 9,888 |
| 4 | `NB Pixel Font Bundle/LCDBlock.ttf` | `assets/art/fonts/LCDBlock.ttf` | 32,452 |
| 5 | `NB Pixel Font Bundle/Zicons.ttf` | `assets/art/fonts/Zicons.ttf` | 31,456 |

Licence: public domain. Total 98,408 bytes.
**Do not** repoint `ui/velvet_theme.tres` at any of these. `gothic_serif.tres`
stays the live font. These are adopted individually, later, on purpose.

### 8.2 Group B — Atmospheric source material (5)

| # | Source path | Destination | Bytes | Note |
| - | --- | --- | --- | --- |
| 6 | `GothicVania Town/GothicVania-town-files/PNG/environment/layers/background.png` | `assets/art/env/source/vania_background.png` | 12,313 | 384x288 `ct=2`. **Source only** — needs desaturate + crush + recomposition before any use. |
| 7 | `GothicVania Town/GothicVania-town-files/PNG/environment/layers/middleground.png` | `assets/art/env/source/vania_middleground.png` | 16,190 | 384x288 `ct=6`. Same treatment. |
| 8 | `GothicVania Town/GothicVania-town-files/PNG/environment/props-sliced/street-lamp.png` | `assets/art/env/source/props/vania_street_lamp.png` | 840 | 35x108. Recolour candidate. |
| 9 | `GothicVania Town/GothicVania-town-files/PNG/environment/props-sliced/chuch.png` | `assets/art/env/source/props/vania_church.png` | 23,008 | 367x263. Most gothic object in the intake. Recolour candidate. |
| 10 | `GothicVania Town/GothicVania-town-files/PNG/environment/props-sliced/well.png` | `assets/art/env/source/props/vania_well.png` | 1,926 | 65x65. Recolour candidate. |

Licence: CC0 1.0, Luis Zuno. Total 54,277 bytes.

> These land in a `source/` subfolder **on purpose**. They are recolour
> candidates, not shippable art. Landing them in `assets/art/env/` directly
> would invite someone to treat them as finished.

### 8.3 Intended destination tree
```
assets/art/
  fonts/                       5 public-domain .ttf, available but not wired
  env/source/                  GothicVania CC0 source images, recolour pending
  env/source/props/            ditto, individual props
```

### 8.4 Optional reference addendum (4) — MAYBE, not required

Include only if a pixel-styled non-combat sub-screen is being planned. These are
construction references; they are **not** to be used on the combat screen.

| # | Source path | Destination | Bytes |
| - | --- | --- | --- |
| 11 | `Dark Dwellers GUI/20251029darkDwellers9SlicesA.png` | `assets/art/ref/dark_dwellers/9slice_a.png` | 908 |
| 12 | `Dark Dwellers GUI/20251029darkDwellers9SlicesB.png` | `assets/art/ref/dark_dwellers/9slice_b.png` | 1,785 |
| 13 | `Dark Dwellers GUI/20251125portraitFrameA.png` | `assets/art/ref/dark_dwellers/portrait_frame_a.png` | 2,458 |
| 14 | `Dark Dwellers GUI/20251125compass.png` | `assets/art/ref/dark_dwellers/compass.png` | 2,221 |

Licence: CC0 1.0, tiopalada. Total 7,372 bytes.
**10 required + 4 optional = 14, within the 20 ceiling.**

### 8.5 Explicitly NOT in this batch
- **No card art.** The five hand-authored SVGs in `assets/cards/` stand.
  `CardView.CARD_ART` is not repointed.
- **No portraits.** Nothing in any pack is close to the spec in
  `assets/portraits/README.md`. `portrait_frame.gd` keeps its silhouette
  fallback and `portrait_texture` stays unset.
- **No UI assets.** `ui/velvet_theme.tres` is untouched.
- **No characters.** All 60 GothicVania NPC frames excluded on direction grounds.
- **No tilesets.** No tilemap in this project.
- **No previews, demos, PSDs, GIFs, `.aseprite`, Phaser code, `.idea`, music.**
- **No `Generic Dark Pixel UI` files at all** — including the 6.4 MB theme.
- **No `TinyPixie2.ttf`** — use the NB copy if it is ever wanted.

### 8.6 Post-import invariants
After this batch, the following must all still hold:
1. `scripts/combat_state.gd` — byte-identical, unmodified.
2. `ui/velvet_theme.tres` — byte-identical; `default_font` still
   `ExtResource("1_font")` -> `res://ui/fonts/gothic_serif.tres`.
3. `scripts/card_view.gd` — `CARD_ART` unchanged; the five SVGs still resolve.
4. `scripts/portrait_frame.gd` — unchanged; silhouette fallback still active
   because neither `undersigned.png` nor `protagonist.png` will exist.
5. `scenes/Combat.tscn` — unchanged; no new `ext_resource`.
6. No new file outside `assets/art/`.
7. 24/24 playtest and 42/42 rules-harness checks still pass.
8. Nothing in `assets/art/` is referenced by any scene or script — a 14-file
   dead-stash by design, to be adopted deliberately.

---

## 9. Verification

Checks performed after writing this file:

- `ART_INTAKE_AUDIT.md` exists at `C:\Users\User\velvet-ruin\ART_INTAKE_AUDIT.md`.
- All 10 KEEP source paths resolved on disk with a real byte count (§8.1, §8.2);
  all 4 optional addendum paths likewise (§8.4). Zero MISSING.
- Working tree re-checked: the only change is the addition of this file.
  `scripts/`, `scenes/`, `ui/`, `assets/`, `project.godot` untouched.
- `data/` remains empty; nothing was added to it.
- No file was imported, copied, converted, or written under `assets/`.

### Bottom line

Four packs, 595 files, 20.29 MB. **10 KEEP, 30 MAYBE, the rest IGNORE.**

Three packs are licence-clean and contribute essentially nothing usable: two are
utility GUI kits that a purpose-built Godot theme already beats, and one is a
bright 16-bit village whose every asset is a recolour job. The single real win
is five public-domain pixel fonts — and importing them buys capability, not
appearance, because `gothic_serif.tres` stays the live font.

The packs also hand the project a clear, useful negative result. VELVET//RUIN's
atmosphere — near-black depth, restrained gilt, elegant sharp shapes, subtle
corruption and glitch — is **absent from all four packs**. None of them contains
a character that fits, a card that fits, a surface texture, a backdrop that needs
only recolouring, or any trace of the corruption treatment. The `portrait_texture`
and `CARD_ART` seams are correctly waiting on bespoke, palette-locked art, and
that art has to be authored in the idiom of `assets/cards/*.svg`.

**This audit stops here. Nothing was imported.**
