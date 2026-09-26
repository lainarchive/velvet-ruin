# ART_DIRECTION_1H.md

**Milestone:** 1H — Character / World Art Direction
**Date:** 2026-09-26
**Baseline:** `5e6032b` — chore: establish velvet ruin baseline
**Companion document:** `ART_INTAKE_AUDIT.md`

> **This is a specification, not an implementation.**
> No asset described here exists. No file in this document has been produced.
> Nothing in this document has been integrated into the game. The project is
> unchanged from the `5e6032b` baseline.
>
> This document defines what the original art of VELVET//RUIN must be, so that
> future art production is consistent rather than repeatedly improvised.

---

## 0. Standing of this document

### 0.1 What this document is

A production specification. It fixes the visual identity of the two
principals, a reusable enemy grammar, the battlefield composition, an exact
asset production list, the relationship to existing card art, the eventual map
language, an explicit register of failure modes, and a pipeline.

### 0.2 What this document is not

- Not a commitment to produce any of it immediately.
- Not a redesign of the combat UI. The UI in `ui/velvet_theme.tres`,
  `scenes/Combat.tscn`, and `scripts/combat_ui.gd` is treated here as fixed
  and correct.
- Not a rewrite of `scripts/combat_state.gd`, which is not referenced by this
  document except to note it is untouched.
- Not a rewrite of the five existing card SVGs. §6 analyses them and extends
  their conventions; it does not alter them.
- Not lore. Sections 1 and 2 describe *appearance and function*, and invent
  minimal supporting detail only where a visual decision requires it.

### 0.3 Current state of the art, stated honestly

| Asset family | Exists? | Count |
| ------------ | ------- | ----- |
| Card illustrations | **Yes** | 5 hand-authored SVGs, `assets/cards/` |
| UI chrome | **Yes** | code-drawn, `ui/velvet_theme.tres` + 4 `_draw()` scripts |
| Signatory bust portrait | **No** | — |
| Undersigned bust portrait | **No** | — |
| Full-body battle figures | **No** | — |
| Enemy art | **No** | — |
| Environment / backdrop art | **No** | — |
| Map art | **No** | — |
| Raster art of any kind | **No** | the project is currently 100% vector |

The only raster-free property is a fact of *history*, not policy. Per §5.1 the
project deliberately becomes vector-plus-raster at 1H.

### 0.4 Two defects found during this audit

Recorded here because they change what 1H art must do. Neither is fixed by this
document; both are code-level and out of scope for an art specification.

**Finding A — the silhouette fallback does not render.**
`scripts/portrait_frame.gd` draws the fallback figure in
`Color(0.024, 0.016, 0.035)` (lines 76–82) onto a panel whose background
composites to approximately `0.025` (line 30, `0.055/0.043/0.06`, then line 31
lays `Color(0.008, 0.004, 0.012, 0.55)` over it). Figure value ≈ background
value. In the captured 1280x720 frame both portrait panels read as **empty
outlined rectangles**; only the accent rim strokes and the enemy's two eye dots
are legible.

*Consequence for 1H:* real portrait art must carry the entire character read on
its own. There is no working fallback to lean on, and no partial degradation to
rely on. Contrast against the panel floor is a hard acceptance criterion (§1.8,
§2.8), not a nicety.

**Finding B — `assets/portraits/README.md` states the wrong dimensions.**
It asks for art composed at ~280x250 (enemy) and ~250x220 (player). The actual
scene rects are **320x310** and **340x268** (`scenes/Combat.tscn:104-112` and
`160-168`). This document specifies the **real** rects (§5.2). The README needs
a separate follow-up edit; it is not edited here.

---

## 1. SECTION 1 — THE SIGNATORY

The player character. Named `THE SIGNATORY` in `scenes/Combat.tscn:186`.
Referenced as "the protagonist" only where grammatical convenience demands it;
in art direction the name is used, because the name is part of the design.

### 1.1 Visual identity

A signatory is someone who has signed. That is the whole character, and it is
a *legal-financial* identity, not an occult or martial one. This is the single
most important discipline for the design: the Signatory's authority is
contractual. They are not a warrior, a mage, a chosen one, or a hunter. They
are a party to an agreement they did not write and cannot exit.

Design consequences that follow from that one idea:

- The character's power is precision, obligation, and leverage — not force.
- Their silhouette should read as *composed under obligation*: straight spine,
  shoulders held, weight settled. Not coiled, not mid-leap.
- Their relationship to weapons is incidental. A blade is a tool in hand, not
  an extension of the body. Contrast sharply with the Undersigned (§2).
- Their costume should carry **paper, ink, or binding** somewhere in the
  design language. This is the shared motif root with §2 and §6.

What the Signatory is *not*: not a shopkeeper, not a clerk, not a bureaucrat
in a drab modern sense, and emphatically not a generic anime protagonist with a
determination expression and a flowing scarf.

### 1.2 Silhouette

Target: readable as a black shape at thumbnail size against `#0c0b10`.

- **Overall proportion:** 7.5 heads tall. Slightly tall, not elongated. Tall
  enough to read as an adult authority, short enough to stay grounded.
- **Primary mass:** a long, straight, columnar coat or overcoat reaching mid-calf.
  A near-vertical silhouette. This is the single strongest shape decision and it
  should be defended: the vertical column is the visual opposite of the
  Undersigned's spread (§2.2), and it is what makes the pair read as
  antagonists rather than two figures in a scene.
- **Shoulders:** level, slightly squared. Not broad, not sloped. The
  silhouette's width is carried by the coat, not by the shoulders.
- **Head:** deliberately small relative to the coat mass. The head reads as a
  quiet element in a large dark shape. This protects the face from being
  over-featured and keeps the character from tipping into anime-hero
  proportion.
- **Legs:** mostly concealed. The coat terminates the silhouette; only boot
  tops are legible. This avoids a "running man" read and simplifies the full-body
  asset substantially.
- **Negative space:** at least one enclosed or near-enclosed void in the
  silhouette — the gap between an arm and the coat body, or a parted coat hem.
  The eye needs somewhere to enter the shape.

**Silhouette test:** fill the figure solid black, place it on `#0c0b10`, shrink
to 120px tall. It must still read as "a person in a long coat standing
squarely." If it reads as a monk, a mage, a soldier, or a generic swordsman,
redraw.

### 1.3 Clothing and design language

Three layers, from body outward. No layer may be decorative-only.

1. **Underlayer — near-black, high collar.**
   Base garment in the `#0c0b10`–`#17151d` range. A standing collar that
   rises to the jaw. Its job is to make the head-to-body transition read as a
   single dark mass, and to give the head a hard edge to sit against.

2. **Midlayer — the coat.**
   Long, straight, columnar. In `#1a1620`–`#241d28` — a *lifted* near-black, so
   it separates from both the underlayer and the background without becoming a
   different hue. Details permitted, and limited to:
   - a single closure line down the front
   - two or three hairline seams
   - a narrow cuff break at each wrist
   - **one** asymmetric element, placed off the vertical axis, to break
     symmetry. Recommended: the coat's left hem is cut shorter and the fabric
     is trained back, as if held or pinned.

   The asymmetry is load-bearing. A fully symmetrical coat is a mannequin. One
   asymmetry converts a garment into a decision somebody made.

3. **Outer accent — burgundy, used once.**
   A single burgundy element in `#8c1d3d` or `#5c1630`. Candidates: an inner
   lining glimpsed at the hem, a collar tab, a sash edge, or a document case
   closure. **One element only.** It must occupy under 5% of the character's
   total area.

   This is the character's only warm mass, and its scarcity is what makes it
   register. Two burgundy accents on one character turns a signature into
   decoration.

**Forbidden on the Signatory:** multiple belts, pauldrons, spikes, chains,
visible armour plating, cape, hood, or any headgear that obscures the face
outline. All of these belong to the generic-fantasy register catalogued in §8.

### 1.4 Hair and face treatment

**Hair.** Dark, close to black — `#17151d` to `#241d28`, i.e. *lighter than the
background* so it separates, but well below the coat in value so it does not
become a highlight. Length to the jaw or just past it. Worn back from the face
with no loose forward-falling strands, and no volume or flicks. Reason: every
forward strand becomes a silhouette contaminant and destroys §1.2's columnar
read. A short, tied-back or tucked treatment is acceptable if it preserves the
jawline.

A single small hair accent in muted violet is permitted, under 2% of head area.

**Face.** This is where the character is won or lost, and where
"generic AI fantasy character art" lives. Rules:

- **Three-quarter, not frontal, not profile.** A three-quarter turn keeps both
  eyes readable in a 320x310 panel while giving the head a directional
  orientation toward the enemy.
- **Eyes: level, narrow, unremarkable.** No large irises, no highlight stars,
  no multiple-ring eyes, no heterochromia. The eyes must not be the most
  detailed thing in the image. Detail budget goes to the mouth and jaw.
- **Brows: straight, low, unarched.** An arched brow is the single most
  reliable marker of the generic-anime-prototype face.
- **Mouth: the focus.** A closed, level, slightly compressed mouth. Reads as
  held composure under strain, not as a smile and not as a snarl.
- **Expression target:** *settled.* The specific failure to avoid is the
  angry/determined clench. A clench turns a character into a trope.
- **No facial hair, no scar crossing the main features, no markings** in this
  milestone. Corruption marks are reserved for the Undersigned (§2.5) so the
  two read as clean/corrupt rather than both marked.
- **Skin rendered in near-neutral, slightly desaturated warm** — the ivory
  family pushed warm and dimmed, around `#c9b8ae` in light and `#5a4a48` in
  shadow. Not pale-white, not tan, not grey-green.

### 1.5 Palette

Drawn from the established family. Values are targets for the lit side; the
shadow side runs darker.

| Role | Hex | Use |
| ---- | --- | --- |
| Ground / deepest | `#0c0b10` | outline, deepest shadow, the void |
| Coat mid | `#1a1620` | primary coat mass |
| Coat lift | `#241d28` | coat highlights, hair upper value |
| Burgundy deep | `#5c1630` | coat shadowed folds, lining |
| Burgundy | `#8c1d3d` | the single outer accent |
| Violet muted | `#6d4bb4` | hair accent only; the player's identity colour in the HUD is `Color(0.584, 0.4, 0.858)`, and art should harmonise with it |
| Ivory | `#f0eff2` | highest highlight only — eyes, one cloth edge, blade glint |
| Skin lit | `#c9b8ae` | face and hands |
| Skin shadow | `#5a4a48` | face and hands in shadow |

**Discipline:** crimson `#dd3561` is the *enemy* and *damage* colour in the
existing UI (`Combat.tscn:18` TurnLabel, `velvet_theme.tres` button hovers). The
Signatory's art should therefore stay **off crimson**. Using crimson on the
player character fights the HUD's semantic assignment. Burgundy is the
player's warm; crimson is the opponent's heat.

### 1.6 Distinctive visual motif

**The closed folio.** A document case, ledger, or folded contract carried
closed. Never open. It may be held at the side, or slung flat against the coat
back where only a corner edge shows.

Why this motif:

- It is the shared root with the Undersigned (§2.6) and with card art (§6.3),
  so one idea propagates through the whole game rather than being invented
  three times.
- It is *closed*, matching the compressed mouth (§1.4) and the squared
  shoulders (§1.2). Character, prop, and pose all say the same thing.
- It gives the full-body art a clean, hard-edged asymmetric element to anchor
  the silhouette, satisfying §1.3's asymmetry requirement without ornament.
- It reads at silhouette scale as a small hard rectangle — legible, and
  distinct from the Undersigned's motifs.

### 1.7 Emotional and readability direction

Three target emotions, in priority order:

1. **Held composure.** The baseline. Under strain, not cracking.
2. **Reluctant familiarity.** This person has done this before and does not
   enjoy it. The single most valuable read, and the one that separates a
   character from a type.
3. **Cold resolve.** Permitted as a *secondary* note for a specific beat, never
   as the resting state.

Explicitly excluded: anger as a resting state, fear, grief, glee, heroism,
and shock. All are one-frame emotions that do not survive a fight lasting
several turns.

**Readability requirements, independent of emotion:**

- The head must be legible at 60px tall.
- The silhouette must not break under a crimson hit-flash wash
  (`portrait_frame.gd:64-65` flashes the full panel).
- The character must not depend on hue alone to be understood. Value structure
  must carry the read, so a greyscale conversion stays legible.

### 1.8 Full-body battle pose requirements

For the full-body stage figure (§5.3). The pose is a *state*, not an action.

- **Weight:** both feet planted, roughly shoulder-width, on the same ground
  line. Weight centred. No mid-stride, no lunge, no airborne.
- **Spine:** vertical. Chin level or slightly down. The head does not tilt
  dramatically.
- **Arms:** held close to the body, elbows in. The arms break the column as
  little as possible. One hand may hold the folio; the other is open, low, and
  relaxed — palm inward, fingers loosely closed.
- **Overall:** the figure occupies its frame as a tall narrow vertical. It
  should be possible to draw a 20px-wide vertical bar over it with only the
  extremities breaking the edges.
- **Required variants** (all at identical camera and scale, so they can be
  swapped without re-staging):
  - `idle` — resting, as described
  - `guard` — arms raised across the body, coat hem compressed
  - `strike` — the only action pose. The folio-hand swings as the strike. This
    is important: the protagonist's attack is a *document*, not a blade slash.
  - `hit` — a small recoil, spine breaking backward, not a thrown-back sprawl
- **Not required at 1H:** walk, run, death, cast, idle variants. Resist the urge
  to build a walk cycle for a card battler.

### 1.9 Portrait requirements

For the bust panel, composed for **320 x 268** (§5.2, not the 280x250 in
`assets/portraits/README.md`).

- **Crop:** head, neck, and shoulders, plus the top edge of the folio at one
  shoulder. Bust fills 70–80% of the panel height. The head sits in the upper
  third; eyes land near the upper-middle.
- **Framing:** because `portrait_frame.gd:38` bottom-anchors the texture
  (`draw_pos.y = sz.y - draw_size.y`), the crop must be composed so the bust
  sits correctly on the panel's bottom edge. Bottom-anchoring is a property to
  design into the crop, not a problem to work around.
- **Facing:** three-quarter, turned toward screen-right — i.e. toward the
  Undersigned, whose panel is at screen-right. The two busts must appear to
  confront each other across the composition.
- **Background:** transparent, or the panel supplies the abyss. The existing
  panel already draws a vignette; the art must not duplicate it.
- **Margin:** minimum 12% clear space on all four sides. The panel draws a
  12px ground shadow at `floor_y = sz.y - 8` and corner ticks of length 12
  (`portrait_frame.gd:44-62`); art intruding on those will be clipped visually.
- **Headroom above the eyes** must survive the 1.6px corner ticks.
- **Value target:** the bust must sit at least two value steps above the panel
  background so it reads against `#0c0b10`. This is a direct response to
  Finding A.

### 1.10 Scale requirements at 1280x720

| Asset | Target size | Displayed at | Effective scale |
| ----- | ----------- | ------------ | --------------- |
| Bust portrait | 640 x 536 (2x) | 340 x 268 | 0.53x |
| Full-body figure | 640 x 1024 (2x) | ~320 x 512 | 0.5x |
| Full-body, centre stage | 480 x 768 (2x) | ~240 x 384 | 0.5x |

Authoring at 2x and displaying at ~0.5x gives headroom for the hit-flash,
the hover lift (`card_view.gd:213` lifts on hover, though that is cards), and
any future larger viewport. Godot's `stretch/mode="canvas_items"` with
`aspect="expand"` means the viewport can exceed 1280x720 on wider displays, so
art should not be authored to a hard pixel budget.

Minimum legible sizes are the real constraint: **the bust's eyes must survive at
340px wide**, and the full-body figure's head must survive at 384px tall.

---

## 2. SECTION 2 — THE UNDERSIGNED

The enemy. Named in `scripts/combat_state.gd:30` as `enemy_name`. The only
enemy in the current prototype; §3 generalises the language beyond it.

### 2.1 Visual identity

The other party. Not a monster, not a demon, not a wraith. A **counterparty** —
something that holds the other end of a contract and is therefore bound by the
same terms.

This is the design spine of 1H and the reason the Undersigned is *not* a
monster: if the game is about debts and signatures, then the thing collecting
the debt is a party to the agreement, not a creature. A monster makes the
theme cosmetic. A counterparty makes the theme structural.

Design consequences:

- The Undersigned **respects the contract**. It does not attack arbitrarily. Its
  menace comes from precision and inevitability, not from rage.
- It should show the *marks* of having signed: something that has been agreed
  to and cannot be withdrawn from.
- It must be legible as *the same kind of entity* as the Signatory. Same world,
  same rules, opposite position.

**What it is not:** a shadow demon, a wraith, a faceless horror, a plague
doctor, a grinning skull, a hooded figure with no face, or a mass of tentacles
and eyes. All of these are the generic-gothic-horror register and are catalogued
as failures in §8.

### 2.2 Silhouette

**Counter-shape to §1.2, deliberately.**

| | Signatory | Undersigned |
| - | -------- | ----------- |
| Primary mass | vertical column | **horizontal spread** |
| Top | narrow head | **wide, high mass** |
| Bottom | long hem, closed | **dispersed, lifted, no ground** |
| Ground contact | both feet planted | **none — it does not touch the ground** |
| Edges | clean, straight, vertical | torn, splayed, diagonal |

- **Proportion:** 6 heads tall — shorter and wider than the Signatory. Broader
  shoulders, a compressed lower body. Reads as *dense* where the Signatory
  reads as *tall*.
- **The upper mass is the head-region.** A wide, high, horizontally-extended
  collar/shoulder structure that the head nests inside. This is the single most
  identifying shape decision and it is what separates the Undersigned from a
  generic hooded figure: the mass is *around and above* the head, not draping
  from it.
- **No legs.** The lower silhouette disperses into trailing, torn, or
  dissolving forms. Combined with §4.2's above-horizon placement, this is what
  makes the Undersigned read as *unbound by the ground plane* while the
  Signatory is bound to it.
- **Asymmetry:** strongly asymmetric, and *differently* asymmetric from the
  Signatory. Where the Signatory's asymmetry is a shortened hem, the
  Undersigned's should be an unmatched trailing element or an uneven collar
  spread.
- **Negative space:** the wide collar should create at least two deep notches
  into the silhouette, so the shape has bite rather than being a slab.

**Silhouette test:** fill solid black, shrink to 120px. It must read as
"something wide and hovering that has shoulders but no legs." If it reads as
"a person in a hood" or "a person in a robe," redraw.

### 2.3 Relationship and contrast to the protagonist

The two are specified as a **matched set**. Contrast must be structural — built
from shared grammar — not a matter of picking opposite colours.

**Shared grammar (both must have all of these):**

- A contract document or seal motif, rendered differently (§1.6 vs §2.6)
- A collar that frames the head — the Signatory's is a standing collar, the
  Undersigned's is a wide spread mass
- One asymmetric element, placed differently
- The same underlying garment construction, corrupted
- Rim lighting, from opposite sides (§1.5 vs §2.4)
- Hair/covering that does not cross the face

**Contrasts that must be present:**

| Axis | Signatory | Undersigned |
| ---- | --------- | ----------- |
| Value | Darkest mass in frame | **Lighter** mass — must read against `#0c0b10` |
| Accent | Burgundy, one element, <5% | **Crimson, more area, permitted to spread** |
| Identity colour | Violet (HUD player) | Crimson (HUD enemy) |
| Ground | bound, planted | unbound, hovering |
| Silhouette | narrow, tall, clean | wide, low-ish, torn |
| Face | fully readable, three-quarter | **partially occluded, never fully hidden** |
| Behaviour | composed | inevitable |

**The value inversion is the key move.** In a near-black game, making the
*enemy lighter* than the protagonist guarantees the enemy reads first, and
gives the player figure the "cut out of the dark" quality that suits a
character who is defined by not being seen clearly. This also directly serves
§3.5 combat readability.

### 2.4 Palette

| Role | Hex | Use |
| ---- | --- | --- |
| Core mass | `#2a2130` | primary body — lighter than Signatory's coat on purpose |
| Deep fold | `#17141d` | interior shadow |
| Corruption deep | `#3a1220` | rot within the garment |
| Burgundy | `#8c1d3d` | structural accent, collar interior |
| **Crimson** | `#dd3561` | **the signature; permitted to spread across 10–18% of area** |
| Crimson bloom | `#ff5c7a` | highest light only, tiny — the "hot" corruption point |
| Violet intrusion | `#6d4bb4` | **under 4%** — a wrong colour inside a wrong place, a corruption tell |
| Ivory | `#f0eff2` | the paper, the seal, one edge highlight |
| Bone / drained | `#8f8478` | desaturated tissue and cloth |

**Discipline:** the Undersigned is the only character permitted crimson at
volume, matching the HUD where crimson is the enemy and damage colour
(`Combat.tscn:18`, and the player's HP bar deliberately reuses `sb_fill` crimson
for both bars). Violet appears on the Undersigned only as a *wrong* colour —
a small intrusion, never a design element. A violet-forward Undersigned
confuses the player-colour semantics the HUD already established.

### 2.5 Supernatural and corruption language

Corruption is the distinguishing treatment. It must be **specific and
sparse**, never a texture overlay.

Four permitted devices, used in combination, with a combined area ceiling of
roughly 20% of the figure:

1. **Wrong geometry.** A garment seam that does not meet, a collar edge that
   resolves into nothing, a panel whose border is off by a pixel or two. This
   is the most sophisticated device and the preferred one — it is unsettling
   without being gory.
2. **Ink bleed into cloth.** Crimson following the logic of a pen stroke
   rather than of a wound: it runs along a seam, pools at a hem, or stops
   mid-fabric. Directly echoes `assets/cards/bleed_the_ledger.svg`, where the
   stain spreads across a page with tendrils and a drip.
3. **Partial duplication.** A limb edge, a collar corner, or the trailing hem
   repeated once at low opacity with a 1–2px offset. This is the corruption/glitch
   register stated in the brief, rendered as a physical artefact in the world
   rather than as a screen effect.
4. **Heat bloom.** One small area of `#ff5c7a` bloom with no light source
   behind it, as though something inside is hotter than it should be.

**Forbidden:** a general glitch shader, scanlines, RGB split, or a noise
overlay applied to the character. §8 explains why — a screen effect on a figure
that is otherwise drawn in a hand-illustrated register reads as a filter, not as
a world. Corruption must be *in the drawing*, not *on* the drawing.

**What the corruption is not:** damage. The Undersigned is not wounded. Every
device above reads as *wrongness*, not as injury. Torn fabric is permitted only
where it reads as deliberate termination rather than as a wound.

### 2.6 Distinctive motif

**The broken seal.** A wax seal, split or half-pressed, worn at the collar or
chest where a Signatory would wear a fastening. It is the same object as the
Signatory's folio (§1.6) and the same object as the seal in
`assets/cards/bleed_the_ledger.svg:31-34` and
`assets/cards/contract_ink.svg:9-14`.

Why this is the right motif to unify the game:

- It gives the player and the antagonist a **shared physical object**, which is
  the entire narrative relationship compressed into one prop each.
- It is already established twice in the card art, so extending it to character
  art makes the game feel like one designed thing rather than three.
- It is *broken*, which distinguishes the Undersigned from the Signatory's
  *closed* folio without needing a colour or shape change.
- It is small, hard-edged, and asymmetric — satisfies the silhouette
  requirements cheaply.

### 2.7 Full-body battle pose requirements

- **Weight:** none. No ground contact. The figure floats or is suspended. Its
  lowest point terminates 8–20% of its height above the ground line, dissolving
  into trailing forms.
- **Spine:** either unnaturally straight and vertical — mirroring the
  Signatory's posture as a mocking echo, which is a strong and cheap narrative
  beat — or a slight forward inclination, as if leaning over a document. The
  echo is preferred.
- **Arms:** extended further from the body than the Signatory's, widening the
  silhouette. Hands open, palms down or forward, fingers separated and
  lengthened — the inverse of the Signatory's loose closed fist. This is a
  deliberate, specific contrast and should be drawn as such.
- **Overall:** a wide, roughly triangular mass, wider at the shoulders, never
  touching down.
- **Required variants** (same camera and scale as §1.8):
  - `idle` — hovering, arms extended
  - `windup` — the corruption visibly advancing; a state change, not a motion
  - `strike` — one extended arm, the crimson bloom at maximum
  - `hit` — minimal reaction. Prefer the corruption *breaking apart* over
    bodily recoil, which reinforces that it is not a body.
- **Note on symmetry:** if the Undersigned is drawn near-symmetrically at rest,
  the asymmetric corruption devices (§2.5) must be strongly placed to carry the
  asymmetry. This is a legitimate alternative to the Signatory's
  garment-asymmetry approach.

### 2.8 Portrait requirements

Composed for **320 x 310** (§5.2, not the 280x250 in
`assets/portraits/README.md`).

- **Crop:** head, collar mass, shoulders, and the broken seal. The crop is
  tighter and higher than the Signatory's — the Undersigned's head is
  *surrounded*, so the frame should show the mass closing around it.
- **Framing:** three-quarter, turned toward **screen-left**, mirroring the
  Signatory's screen-right turn. The two busts must confront each other.
- **Vertical position:** because the texture is bottom-anchored, the mass
  should sit low in the crop with clear space above, so the wide collar has
  somewhere to spread. A tight crop that fills edge to edge will fight the
  panel's corner ticks.
- **Face:** partially occluded — by the collar, by hair, or by a corrosion
  boundary. **Never fully hidden.** One eye must read. A completely faceless
  portrait is unreadable at 320px and lands in §8's failure list.
- **Value target:** the mass must sit at least two value steps above the panel
  background, and *higher* than the Signatory's bust in the same frame
  (§2.3). Response to Finding A.
- **Margin:** minimum 12% clear on all sides, same reason as §1.9.
- **The eye read must survive:** the single visible eye is the emotional
  anchor of the fight. It is permitted to be wrong — too wide, pupil
  displaced, iris the crimson bloom colour — but it must be a *deliberate
  wrong*, and it must be the highest-contrast detail in the panel.

### 2.9 Scale requirements

| Asset | Target size | Displayed at | Effective scale |
| ----- | ----------- | ------------ | --------------- |
| Bust portrait | 640 x 620 (2x) | 320 x 310 | 0.5x |
| Full-body figure | 768 x 768 (2x) | ~384 x 384 | 0.5x |

The Undersigned's full-body target is square rather than tall, because §2.7's
wide-triangular mass needs width more than height. Authoring square is a
deliberate signal to the illustrator that this figure is not a tall thing.

Minimum legible size: the single visible eye must survive at 320px panel width.
If it does not, the crop is wrong, not the size.

---

## 3. SECTION 3 — ENEMY LANGUAGE

A reusable grammar. **No roster is designed here.** The Undersigned (§2) is the
reference implementation; everything else derives from these rules.

### 3.1 Silhouette rules

Every enemy must satisfy all five:

1. **Distinguishable in pure black at 120px tall.** No two enemies in the same
   encounter may share a silhouette class. If a player cannot tell them apart
   from shape alone, the art has failed regardless of colour.
2. **One dominant gesture.** A strong single read — tall, wide, low, angular,
   suspended. Not a compromise between two shapes.
3. **A ground relationship that is a decision.** Standing, hovering, emerging
   from, partially sunk into, or absent. Chosen deliberately per enemy and
   visible in silhouette. Ground relationship is the fastest signal a player
   reads, and it is currently under-used as a design axis.
4. **At least one void or notch.** No enemy is a solid slab.
5. **Visible head-region.** Every enemy has a locatable head or head-equivalent.
   An enemy whose "face" is undeterminable cannot carry intent, and intent is
   the game's core information.

### 3.2 Proportion rules

- **Varied, and varied on a schedule.** Encounters should not present two
  similar-proportioned enemies. Track a roster-wide proportion spread:
  tall/narrow, wide/low, compact/dense, small/light, huge/dark.
- **The tallest enemy in a scene sets the difficulty read.** Very large
  silhouettes must reserve that scale for genuinely threatening enemies, or the
  scale stops meaning anything.
- **Heads are never enlarged for readability.** Enlarge silhouette, silhouette
  features, or gesture. A big-headed small enemy reads as cartoon, which is
  §8's "generic" failure.
- **Proportions must survive the 320x310 portrait crop.** A design that only
  works full-body will not port to the panel.

### 3.3 Palette rules

- **Enemies live in the crimson/burgundy half** of the palette. The violet half
  belongs to the player and to intent. An enemy that is predominantly violet
  will be misread as friendly-state.
- **Value carries identity, hue carries category.** Within the enemy set, hue
  is used to say "family"; value is used to say "individual." A palette with
  many similar hues and many similar values produces an unreadable roster.
- **Every enemy needs a lighter mass than the background.** Same rule as §2.3.
  Near-black enemies on a near-black battlefield do not read, and this is the
  single most common failure in dark games (§8).
- **Ivory is rationed.** It means "eye, edge, or weakness." If everything is
  ivory-highlighted, nothing is.
- **No green, no saturated blue, no pure black fills.** Black is `#0c0b10` and
  is used as an outline and a void, never as an enemy's whole body.

### 3.4 Corruption and detail treatment

Reuse §2.5's four devices, with a **ceiling that scales with threat**: an
ordinary enemy carries 5–10% corruption area, a major enemy 15–25%, a
conclusion-tier presence more. Corruption area is a readable difficulty signal
and should be used as one.

Additional rules:

- **At least one enemy per encounter should have no corruption at all.** Pure
  silhouette, clean drawing, no devices. A consistent corruption vocabulary
  without a clean counter-example stops reading as corruption and starts
  reading as art style.
- **Devices must be placed asymmetrically.** Centred corruption reads as a
  pattern or a costume, not as a wound in reality.
- **No screen-space glitch effects on enemies.** Same rationale as §2.5.

### 3.5 Combat readability

The governing requirement. During a turn the player has roughly a second to
parse an enemy. Rules, in priority order:

1. **Silhouette first, then face, then detail.** Detail is the last thing read
   and may be lost entirely at small sizes. No design may depend on detail for
   its primary identification.
2. **The intent is a UI element, not art.** Intent already reads as text
   (`combat_ui.gd:124`, `IntentLabel` in `Combat.tscn:96-102`) and must
   continue to. Art must not be asked to carry intent by colour alone.
3. **No enemy may be occluded by another enemy.** Encounter layout must keep
   each enemy's silhouette in clear space.
4. **No enemy may sit on top of the horizon band or the ember marks.** See §4.7.
5. **Value separation is mandatory.** Where an enemy overlaps another
   silhouette or the background, a rim light or a value step must separate
   them. Enforce in the greyscale check (§9.6).
6. **Flash tolerance.** `portrait_frame.gd:64-65` washes the panel in
   `Color(0.937, 0.278, 0.38, _flash * 0.4)` on hit. An enemy whose readability
   depends on a mid-tone will be erased for the duration of the flash. Design
   a bright anchor — the eye, a bloom, an edge — that survives a 40% crimson
   wash.

### 3.6 Visual hierarchy

- **One focal enemy per encounter.** Others are lower contrast, smaller, or
  further back. The current prototype has exactly one enemy and §4 preserves
  that focus; the grammar is written for when that changes.
- **The elite always wins the value fight.** The most important enemy present
  gets the highest value and the most complex silhouette. Hierarchy is
  communicated before any stat is read.
- **Corruption area ranks above size.** A smaller enemy with more corruption
  outranks a large clean one. This keeps the roster's difficulty read
  independent of sprite dimensions.
- **Enemies never out-shout the player card art.** The hand is the player's
  primary read; enemies must not compete with the card wells for attention.

---

## 4. SECTION 4 — BATTLEFIELD

**This section does not redesign the UI.** `scenes/Combat.tscn`,
`ui/velvet_theme.tres`, and `scripts/combat_ui.gd` are fixed. What follows
defines where art goes within the existing composition.

### 4.1 The existing 1G composition, as measured

Read directly from `scenes/Combat.tscn` at 1280x720:

| Element | Rect | Notes |
| ------- | ---- | ----- |
| `BackdropFill` | 0,0 → 1280,720 | `Color(0.024, 0.016, 0.035)` |
| `EdgeOrnament` | full | corner ticks, `backdrop_ornament.gd` |
| `Stage` | full | horizon at `y = 0.55 × 720 = 396` |
| `TurnLabel` | 460,8 → 820,30 | 18px, top centre |
| `EnemyPortrait` | **830,66 → 1150,376** | 320x310 |
| `EnemyIdentity` | 830,384 → 1150,436 | name + HP |
| `IntentRow` | 830,444 → 1150,468 | intent text |
| `PlayerPortrait` | **40,372 → 380,640** | 340x268 |
| `PlayerIdentity` | 40,648 → 380,706 | name + HP/state |
| `SideColumn` | 1118,520 → 1244,704 | energy, piles, End Turn |
| `HandColumn` | 388,500 → 1116,706 | cards, `HandClip` min height 196 |
| `OverlayDim` | full | outcome overlay |

### 4.2 The y=396 spine — the composition's existing grammar

The single most important structural fact, and it is not currently documented
anywhere: **the horizon splits the two principals.**

- `EnemyPortrait` spans y 66–376 — **entirely above** y=396.
- `PlayerPortrait` spans y 372–640 — **entirely below** y=396.
- The horizon band occupies y 362–396, precisely the gap between them.

The Undersigned hovers above the line; the Signatory stands below and in front
of it. `StageOrnament`'s single divider at y=396 is doing real compositional
work, not decoration.

**1H treats this as the spine of the battlefield and preserves it.** Art must
strengthen the above/below relationship, not flatten it. Concretely:

- Signatory art sits **below** y=396, with a visible ground contact.
- Undersigned art sits **above** y=396, with none.
- Nothing straddles the line except the band itself.

This gives the two characters a relationship that needs no lore: one is
anchored, one is not.

### 4.3 Placement

**Signatory (below the line, left-of-centre).**
Full-body figure occupies the free region between the player panel and centre:
approximately x 400–600, feet at y ≈ 470. This is below the horizon, forward of
the Undersigned, and it does not collide with `PlayerPortrait` (ends x=380) or
`HandColumn` (starts x=388, y=500). The figure's feet at y≈470 clear the hand
column's top edge by 30px.

**Undersigned (above the line, right-of-centre).**
Full-body figure occupies approximately x 700–830, lower edge at y ≈ 380. It
hovers just above the band and just left of `EnemyPortrait` (starts x=830). It
is *behind and beside* its own panel, which is the correct relationship: the
panel is the identity card, the figure is the presence.

**Facing.** The two figures face each other across the centre gap
(x 600–700). The Signatory faces screen-right; the Undersigned faces
screen-left. This mirrors the bust orientation (§1.9, §2.8) so panel and stage
agree.

### 4.4 Empty-space usage

Measured void regions in the current 1G frame:

| Region | Extent | Area of screen |
| ------ | ------ | -------------- |
| Upper-left quadrant | x 0–830, y 0–360 | **~28%** |
| Centre stage gap | x 380–830, y 60–500 | ~21% |
| Left of player panel | x 0–40 | negligible |

**Per the 1H decision, the upper-left quadrant receives environment art.** It is
the largest single void and it currently reads as unfinished rather than
composed. The centre gap remains deliberately open — it is where the two figures
face each other, and filling it would kill §4.2's relationship.

**Rules for all negative space:**

- Negative space must be *composed*, not merely empty. Where nothing is placed,
  something must still be doing work: a value gradient, a haze band, an
  architectural edge entering frame.
- No two adjacent voids of equal value. If a region is `0.025`, something within
  400px must not also be `0.025`.
- The safe area already asserted by `playtest_1c.gd` (16/12/16/14 margins) is
  inviolable. Environment art may pass *behind* it, never into it.

### 4.5 Background treatment

A single **full-bleed recessive environment layer**, behind all UI.

- **Extent:** 1280x720 minimum, authored at 2560x1440 (2x) to survive
  `aspect="expand"` on wider displays.
- **Architecture:** *suggested, not literal.* Vertical rhythm — piers, arches,
  a colonnade, a high vault implied by a value change rather than by drawn
  detail. The environment is a room the fight happens in, not a place the player
  explores. Anything that reads as a traversable space is over-designed for 1H.
- **Value:** the darkest element on screen. Range `#0c0b10` to roughly `#1a1620`.
  It must never exceed the Signatory's coat value (`#1a1620`) anywhere it sits
  behind them, or the character stops separating.
- **Placement:** weighted to the upper-left per §4.4, thinning toward the right
  where the HUD lives. The architecture's perspective lines should converge
  toward the centre gap, so the two figures are framed by the room rather than
  floating in it.
- **No detail below a threshold.** A background element that cannot be
  distinguished from the field behind it should be removed, not dimmed. The
  current code's philosophy applies: `backdrop_ornament.gd` draws four corner
  ticks and nothing else.
- **Explicitly:** no sky, no windows with light through them, no moon, no
  stars, no exterior view. This is an interior.

### 4.6 Horizon and ground treatment

The ground plane is the line at y=396, and it must read as a *floor the
Signatory stands on* and *a surface the Undersigned does not touch*.

- **Ground shadow.** The Signatory's full-body figure requires a contact
  shadow — a soft, low-opacity ellipse or a hairline — at its feet, anchoring
  it below the line. Without it the figure floats and §4.2 collapses. This
  mirrors `portrait_frame.gd:44-46`, which already draws a ground shadow line
  for busts.
- **The Undersigned casts no shadow.** This is the cheapest and most legible
  expression of §2.2's no-ground-contact rule. Its absence of a shadow should be
  noticeable.
- **No rendered floor texture.** A reflective or tiled floor would compete with
  the figures and add a plane the game does not use. The ground is implied by
  the shadow and the horizon line, nothing more.
- **The horizon divider stays a single hairline.** It is doing structural work
  (§4.2). It must not be widened, textured, or embellished.

### 4.7 Atmospheric elements

Permitted, with strict budgets:

| Element | Budget | Purpose |
| ------- | ------ | ------- |
| Haze / depth gradient | 1, vertical, ≤12% opacity | separates figures from environment |
| Slow drift motes | ≤8 visible, 1–2px, ≤20% opacity | life without noise; replaces §4.8's ember dots |
| Ground contact shadow | 1 per grounded figure | §4.6 |
| Corruption bleed | ≤2 locations, tied to the Undersigned | §2.5 |
| Vignette | 1, corners only | frames the composition |

**Forbidden:** rain, snow, falling petals, fog banks, god rays, floating
lanterns, and any particle field dense enough to read as weather. Each is a
generic-gothic shortcut and each competes with the figures. The game's
atmosphere is *stillness with pressure*, not weather.

### 4.8 What stays and what goes

**KEEP — these are correct and should remain:**

| Element | Source | Why |
| ------- | ------ | --- |
| Corner ticks | `backdrop_ornament.gd:22-30` | 4 marks, 22px, `#0c0b10`-scale. Correct restraint. |
| Horizon band | `stage_ornament.gd:18` | Establishes y=396, which is the composition spine. |
| Horizon divider hairline | `stage_ornament.gd:20` | Structural, §4.6. |
| Hairline portrait frames | `portrait_frame.gd:49-62` | Matches the theme's 1px language exactly. |
| Accent corner ticks on portraits | `portrait_frame.gd:58-61` | Binds portraits to `EdgeOrnament`. |
| Crimson/violet mode split | `portrait_frame.gd:45,52` | Semantically correct. |
| Ground shadow on busts | `portrait_frame.gd:44-46` | Consistent with §4.6. |
| Negative space in the centre | `Combat.tscn` layout | Required by §4.2. |

**REMOVE or REPLACE — when real art lands:**

| Element | Source | Why | Replaced by |
| ------- | ------ | --- | --------- |
| **Ember dots** | `stage_ornament.gd:26-32` | 5 hard-coded `draw_circle` marks at fixed offsets. Once figures and a real ground exist, they read as debris floating at a fixed screen position, unrelated to anything. They are the weakest element in the current frame. | Drift motes (§4.7), or nothing. |
| **Procedural silhouette** | `portrait_frame.gd:67-94` | Does not render — see Finding A. | Real bust art (§5.2). |
| Flat `BackdropFill` | `Combat.tscn:40` | A single flat fill cannot be "near-black with depth." | Environment layer (§4.5). |

**RETAIN AS FALLBACK — do not delete:**

`StageOrnament` and `BackdropOrnament` should both keep working with no art
present. They are the game's baseline composition, and the 55-check playtest
harness asserts against the current geometry. Any replacement must be additive
until the playtest confirms otherwise.

### 4.9 How character art becomes the visual anchor

The anchor is achieved by **contrast budget**, not by scale:

1. **Value hierarchy.** Environment (`#0c0b10`–`#1a1620`) < Signatory
   (`#17151d`–`#241d28`) < Undersigned (`#2a2130`–`#ff5c7a` accents). The
   Undersigned is the brightest thing on screen by design (§2.3).
2. **Detail hierarchy.** The figures carry the only detailed drawing on screen.
   Everything else is a value field, a hairline, or a mote.
3. **Chromatic exclusivity.** Crimson and violet are spent on the two
   principals and the HUD. The environment uses neither in volume. This is why
   §4.5 caps environment value rather than giving it colour.
4. **The horizon does the framing.** §4.2's split places each figure in its own
   half of the screen. No extra compositional scaffolding is needed.
5. **Cards stay the densest read.** The hand remains the player's focus (§3.6).
   Figures must not out-detail the card art wells.

---

## 5. SECTION 5 — ART ASSET SPECIFICATION

### 5.1 Format policy

- **Character and environment art: PNG with alpha.** Chosen at 1H. Character
  illustration is painterly and anime-influenced, which vector is a poor fit
  for; `assets/portraits/README.md` already specifies `.png` filenames, and
  `portrait_frame.gd` already loads them via the `portrait_texture` seam.
- **Card art: hand-authored SVG**, unchanged, 256x180, per §6.
- **UI chrome: none.** The UI stays code-drawn. No bitmap UI.
- **Authoring resolution: 2x.** All raster art authored at 2x target
  (spec tables below), displayed at ~0.5x. This gives headroom for
  `aspect="expand"` viewports larger than 1280x720 and for the hit-flash wash.
- **This is a deliberate change:** the project goes from 100% vector to
  vector-plus-raster. Recorded here so it is a decision rather than a drift.

**Alpha is mandatory** on all character and environment art. The battlefield
and the panels composite onto live backgrounds; a baked background would
destroy §4.5's value hierarchy and make hit-flash and rim lighting impossible.

### 5.2 Destination tree

```
assets/art/
  characters/
    protagonist/
      signatory_bust.png
      signatory_battle.png
    undersigned/
      undersigned_bust.png
      undersigned_battle.png
    enemies/
      (no files — no roster designed at 1H)
  environment/
    backdrop_01.png
  ui/
    (no files — UI is code-drawn; this directory is reserved, not populated)
  fonts/
    (empty — see ART_INTAKE_AUDIT.md §8 for the reviewed font candidates)
```

`assets/portraits/` remains the *existing* seam directory. 1H art lives in
`assets/art/`; wiring the two together is a later code change, not part of this
specification.

### 5.3 ESSENTIAL

The minimum set that changes how the game looks. Only these two files are
required before the game stops showing empty panels.

| # | Filename | Format | Resolution | Alpha | Use | Exists |
| - | -------- | ------ | ---------- | ----- | --- | ------ |
| E1 | `assets/art/characters/protagonist/signatory_bust.png` | PNG-8/16 | **640x536** (2x of 340x268) | **Required** | `PlayerPortrait.portrait_texture`; bust per §1.9 | **No** |
| E2 | `assets/art/characters/undersigned/undersigned_bust.png` | PNG-8/16 | **640x620** (2x of 320x310) | **Required** | `EnemyPortrait.portrait_texture`; bust per §2.8 | **No** |

**E1/E2 are the only zero-code-change wins in 1H.** `portrait_frame.gd` already
accepts a texture, and `combat_ui.gd:37-60` already resolves
`res://assets/portraits/undersigned.png` and `.../protagonist.png` silently when
absent. Landing these two files at those paths requires no script or scene edit
whatsoever — the panels fill in and the silhouette stands down automatically.

**E1/E2 acceptance criteria:**
- Value separation ≥2 steps above the panel background (Finding A)
- 12% minimum clear margin on all sides
- Reads correctly in greyscale
- Survives a 40% crimson wash (`portrait_frame.gd:65`)
- The two busts read as confronting each other from 320px apart

### 5.4 OPTIONAL

High value, no new scene infrastructure required beyond a simple textured
rect, but not needed for the panels to stop reading as empty.

| # | Filename | Format | Resolution | Alpha | Use | Exists |
| - | -------- | ------ | ---------- | ----- | --- | ------ |
| O1 | `assets/art/environment/backdrop_01.png` | PNG-8/16 | **2560x1440** (2x of 1280x720) | **Required** | Full-bleed environment layer, §4.5, weighted upper-left | **No** |
| O2 | `assets/art/characters/protagonist/signatory_battle.png` | PNG-8/16 | **640x1024** | Required | Full-body Signatory, stage placement per §4.3 | **No** |
| O3 | `assets/art/characters/undersigned/undersigned_battle.png` | PNG-8/16 | **768x768** | Required | Full-body Undersigned, hovering, §4.3 | **No** |

**Note on O2/O3:** these require either new scene nodes or a replacement of the
existing portrait panels with larger art. Both are scene changes. The 55-check
`playtest_1c.gd` harness asserts against current rects, so adding figures
without updating that harness risks breaking layout assertions. This is why
they are OPTIONAL and not ESSENTIAL.

### 5.5 FUTURE

Specified so they are not reinvented later. **None of these are in scope for
1H and none exist.**

| # | Filename | Format | Resolution | Use |
| - | -------- | ------ | ---------- | --- |
| F1 | `assets/art/characters/protagonist/signatory_battle_guard.png` | PNG | 640x1024 | `guard` pose, §1.8 |
| F2 | `assets/art/characters/protagonist/signatory_battle_strike.png` | PNG | 640x1024 | `strike` pose, §1.8 |
| F3 | `assets/art/characters/protagonist/signatory_battle_hit.png` | PNG | 640x1024 | `hit` recoil, §1.8 |
| F4 | `assets/art/characters/undersigned/undersigned_battle_windup.png` | PNG | 768x768 | `windup`, §2.7 |
| F5 | `assets/art/characters/undersigned/undersigned_battle_strike.png` | PNG | 768x768 | `strike`, §2.7 |
| F6 | `assets/art/characters/undersigned/undersigned_battle_hit.png` | PNG | 768x768 | `hit`, §2.7 |
| F7 | `assets/art/characters/enemies/<name>_bust.png` | PNG | per §3.2 | Enemy portraits, 320x310 |
| F8 | `assets/art/characters/enemies/<name>_battle.png` | PNG | per §3.2 | Enemy full-body |
| F9 | `assets/art/environment/backdrop_02..NN.png` | PNG | 2560x1440 | Encounter-specific environments |
| F10 | `assets/art/environment/ground_shadow_signatory.png` | PNG | ~256x64 | Contact shadow, §4.6 |
| F11 | `assets/art/environment/motes.png` | PNG | 512x512 | Drifting motes, replaces ember dots, §4.8 |
| F12 | `assets/art/map/node_<type>.png` | SVG or PNG | 128x128 | Map nodes, §7 |
| F13 | `assets/art/map/path_<style>.png` | SVG or PNG | tileable | Map edges, §7 |

**F1–F6 are pose variants of art that does not yet exist.** They are listed so
that when the base figure is drawn, the pose sheet is planned rather than
retrofitted. A figure redrawn six times is cheaper than six figures.

### 5.6 Naming convention

- Lowercase, `snake_case`, no spaces, no dates, no version suffixes.
- Character files are named for the *character*, not the art: `signatory_*`,
  `undersigned_*`, never `portrait_final_v3.png`.
- One concept, one file. No "alternates" in shipped paths.
- Poses use the suffix `_battle_<pose>`; busts use `_bust`.

---

## 6. SECTION 6 — CARD ART RELATIONSHIP

The five SVGs in `assets/cards/` are **not to be rewritten**. This section
records what they already do, and extends their conventions.

### 6.1 What the five cards already establish

Read from source. All five are 256x180 SVG, flat vector, no gradients, no
filters, no raster.

| File | Subject | Dominant accent | Structure |
| ---- | ------- | --------------- | --------- |
| `velvet_cut.svg` | diagonal cut through layered velvet | ivory on burgundy | 3 stacked drapery bands + one clean diagonal |
| `gilt_collapse.svg` | gilded arch fracturing | gilt + crimson | symmetric arch + one jagged vertical fracture |
| `smoke_veneer.svg` | gloved hand drawing smoke through a thread | crimson thread | taut line + one S-curve woven over/under |
| `bleed_the_ledger.svg` | open ledger, seal, spreading stain | crimson on ivory | two-page symmetry + asymmetric organic stain |
| `contract_ink.svg` | pen, ink drop, luminous seal | violet + crimson | one diagonal + concentric rings |

**The conventions they collectively establish:**

1. **One idea per card.** A single gesture or object. Not a scene.
2. **One dominant accent**, 1–2 secondary. `smoke_veneer` and
   `bleed_the_ledger` are crimson-led; `contract_ink` is violet-led; the other
   two are burgundy- and gilt-led.
3. **Geometry is architectural or calligraphic** — arches, ledger pages, seals,
   blades, threads. Never organic clutter, never a landscape.
4. **A documented palette comment on line 2 of every file.** This is a real,
   consistent in-file convention and §6.4 makes it binding for new art.
5. **Asymmetry within symmetry.** `gilt_collapse` and `bleed_the_ledger` are
   structurally symmetric with one asymmetric intrusion (the fracture; the
   stain). `velvet_cut` and `contract_ink` are single diagonals.
6. **Near-total absence of the background.** `velvet_cut` uses `#380d1b`–`#5c1630`
   fills but never the clear colour; `contract_ink` keeps the page at 12% opacity.
   Cards are objects floating in the card well, not scenes.
7. **Restrained detail.** Roughly 12–20 drawing operations per card. Line
   weights are thin (1–2.6 units) and consistent.

### 6.2 What character art must share with cards

These five are the project's reference standard. Character art must match them
on:

| Shared property | Requirement |
| --------------- | ----------- |
| **Palette** | Exactly the family in §1.5 and §2.4. No new hues, at any saturation. |
| **Value structure** | Objects sit on a dark field; the brightest element is small and deliberate. |
| **Thin-line economy** | Character art should be *simpler* in line treatment than the cards, not busier. Large shapes, few edges. |
| **Architectural bias** | Silhouettes are built from a few decisive shapes, like the arch in `gilt_collapse` — not assembled from detail. |
| **One asymmetric intrusion** | §1.3 and §2.2 both require it; the cards already do it. |
| **Gilt is a highlight, not a surface** | `gilt_collapse` uses `#a97f3c` as strokes and `#6b4d22` as structure. Gilt is never a fill area. |
| **Document/seal motif** | §1.6 and §2.6 both derive from motifs already in `bleed_the_ledger` and `contract_ink`. |

### 6.3 What must remain unique to cards

- **Cards are objects; characters are presences.** Card art shows a *thing* —
  a blade, a seal, a page. Character art shows a *figure*. Do not put a
  character portrait in a card well at 1H; the well is 256x180 and a bust there
  would be illegible and would duplicate the panel.
- **Cards get ivory.** `bleed_the_ledger` is the one card led by a large ivory
  field, and it works because it is a page. Character art uses ivory as a
  highlight only (§1.5, §2.4).
- **Cards get concentric rings.** `contract_ink`'s seal rings are a card
  device. Do not propagate ring motifs into character silhouettes — the game
  already rejected circular UI in 1G.
- **Cards are flat vector; characters are raster.** The register difference is
  intentional. What must match is palette and value discipline, not medium.

### 6.4 What future card illustrations must follow

Binding rules for any card added after the current five:

1. **256x180 SVG.** Same canvas, same viewBox, no exceptions.
2. **Palette comment on line 2**, listing every hex used. Continue the existing
   convention exactly.
3. **One idea.** One gesture, one object, one moment. If it needs a second
   sentence to describe, it is two cards.
4. **One dominant accent** from the family; ivory or gilt as the secondary at
   most.
5. **12–20 drawing operations.** If a card is exceeding that, it is a
   composition problem, not a detail problem.
6. **No background fill** at more than ~15% opacity. The card well supplies the
   field.
7. **Motif continuity.** Prefer motifs already established — seal, ledger,
   thread, arch, blade, ink, drapery — before inventing new ones. A new motif
   must earn its place across at least two cards.
8. **No characters, no portraits, no faces** at 1H.
9. **Must read at 140x186**, the card's display size
   (`card_view.gd:46`, `custom_minimum_size = Vector2(140, 186)`). The art well
   is smaller still. Test at well size, not card size.
10. **Must survive the unplayable state**, where `modulate` drops to
    `Color(0.78, 0.74, 0.78)` (`card_view.gd:195`) and the style desaturates.
    A card that only works in full colour is not finished.

---

## 7. SECTION 7 — MAP / WORLD ART

Direction only. **The map is not designed here.** This section exists so that
when it is, it does not arrive as a different game.

### 7.1 Environment language

Identical to §4.5. The map is a different view of the same architecture.

- **Interior.** Arches, piers, colonnades, vaulted space. Implied through
  value and rhythm, not drawn detail.
- **Stillness.** No weather, no sky, no exterior (§4.7's forbidden list applies
  in full).
- **Depth through value only.** Far = darker and lower contrast. This is the map's
  primary depth cue and it matches the battlefield's.

### 7.2 Texture

- **No tileable surface texture is currently required.** If one is introduced
  it must be near-invisible: a value shift of under 4% that is felt rather than
  seen. The 1G UI is built on flat fields and hairline borders; a visible
  texture would break that immediately.
- **Grain is permitted; pattern is not.** Fine monochrome noise at ≤3% opacity
  unifies large dark areas. Repeating geometric patterns read as a generic RPG
  map backdrop.
- **No parchment, no paper grain on the map itself.** Parchment is card
  language (`bleed_the_ledger`), and using it on the map would collapse the
  distinction §6.3 depends on.

### 7.3 Architecture

- **One architectural grammar shared with §4.5.** Vertical rhythm, arches, a
  repeated pier spacing. The map should look like a floorplan of the room the
  fight happens in.
- **Symmetry with one break.** The architecture is regular; one bay, one arch,
  or one span is collapsed or doubled. This mirrors the cards' symmetric-with-
  one-asymmetric-intrusion convention (§6.1) and the characters' single
  asymmetric element (§1.3, §2.2). One rule, applied everywhere.
- **Rooms, not corridors-as-lines.** Node areas should be readable as spaces
  with boundaries, not as connective tissue.

### 7.4 Atmosphere

- **The map is quieter than the battlefield.** The fight is the loud moment. The
  map is the held breath.
- **Motes are permitted** at lower density than §4.7 — these become the map's
  only motion, at ≤4 visible.
- **No corruption on the map itself.** Corruption belongs to the Undersigned and
  its enemies. Putting it in the environment would make the *world* corrupted
  and remove the Undersigned's ownership of the theme.
- **One corrupted region maximum**, if the map eventually supports it, and it
  should read as a single event rather than a biome.

### 7.5 Node and icon style

- **Hairline, not filled.** Node markers follow the UI's 1px language
  (`velvet_theme.tres` is built entirely on 1px borders). A node is a thin
  outlined shape with a small interior mark, not a solid token.
- **Shape carries meaning, colour reinforces it.** Node types are
  distinguishable by silhouette alone, exactly as §3.1 requires for enemies.
  Colour is the second read, never the first.
- **No circular tokens.** Consistent with 1G's rejection of circular portrait
  UI. Angular, tapered, or notched forms only.
- **Icons in the same palette, at the same value range** as §1.5/§2.4. No
  greens, no browns, no gold saturation.
- **Restraint budget:** if more than roughly 8 node types exist, the node
  language has failed and types must be merged. Contrast with §3.1's
  "no two enemies share a silhouette class" — node types are the inverse case
  and need *fewer* distinct shapes because they appear simultaneously.
- **No numerical or letter badges on nodes.** Status is communicated by shape
  fill and interior mark, matching how the HUD already treats pile counts as
  quiet (`combat_ui.gd:127-128`).

### 7.6 Palette

The map uses the same five families and nothing more:
`#0c0b10` field, `#17151d`–`#241d28` structure, `#8c1d3d`/`#5c1630` burgundy
accent, `#6d4bb4` violet for player-affiliated marks, `#f0eff2` ivory for the
active or selected state only.

**Active/selected is the only place ivory is spent at volume**, and it is
spent on a hairline, not a fill.

### 7.7 Relationship to character art

- **Same palette, same value range, same hairline discipline.** The map is the
  environment of §4.5; the characters are the environment's occupants.
- **Characters must read against map nodes.** A node and a character may not use
  the same silhouette language. If the Signatory's columnar coat (§1.2) shares a
  shape with a node marker, one of them is wrong.
- **Node markers echo character motifs sparingly.** A broken-seal node
  (F12/F13) is legitimate because §2.6 established the motif. Echoing it in more
  than one node type dilutes it.
- **Scale continuity.** A character bust at 320x310 and a map node at 128x128
  must feel like the same drawing system at two sizes. Test both in one
  contact sheet before either is signed off.

---

## 8. SECTION 8 — WHAT NOT TO DO

An explicit register of failure modes. Each is a real and common way this
project could go wrong.

### 8.1 Character and portrait failures

| # | Failure | Why it is fatal |
| - | ------- | --------------- |
| 1 | **Generic AI fantasy character art.** Symmetrical face, large irises, brow highlight, floating rim light, no specificity. | Reads as a stock asset. Directly contradicts §1.4's eye and mouth budget. This is the single largest risk to 1H. |
| 2 | **Generic anime protagonist.** Determination clench, windswept fringe, flowing scarf, big expressive eyes, heroic 8-head proportion. | Exactly the archetype §1.2 and §1.4 were written to exclude. |
| 3 | **Giant circular portrait frames.** Radar dials, portholes, roundels. | Explicitly rejected in 1G. `portrait_frame.gd` already replaced circular dials with rectangular panels; reverting is a regression. |
| 4 | **Non-differentiating near-black figures.** Bodies at `#0c0b10` on a `#0c0b10` field. | This is Finding A restated as a design rule. A figure that cannot be seen is not art. Every figure needs ≥2 value steps of separation. |
| 5 | **Fully faceless or fully hooded enemies.** | Unreadable at 320x310 and cannot carry intent (§3.1 rule 5). §2.8 requires one visible eye. |
| 6 | **Crimson on the player, violet on the enemy.** | Inverts the HUD's established semantics (`velvet_theme.tres` assigns violet to player, crimson to enemy/damage). Player art uses burgundy; enemy art uses crimson (§1.5, §2.4). |
| 7 | **Symmetric-and-static characters.** | Reads as a mannequin or a costume. §1.3 and §2.2 both require one asymmetric element. |
| 8 | **A silhouette that shares a class with another character.** | The fastest read in the game is shape. Two similar silhouettes destroy identification regardless of colour. |

### 8.2 Interface and composition failures

| # | Failure | Why it is fatal |
| - | ------- | --------------- |
| 9 | **Pixel-art UI mixed into the vector interface.** Chunky 9-slice borders, 16px bitmap buttons, tiled frames. | Two rendering registers in one screen. The whole point of the `ART_INTAKE_AUDIT.md` conclusion was that the packs fail here. |
| 10 | **Excessive ornamental borders.** Double frames, corner filigree, scrollwork, filigree inside filigree. | The live theme is 1px borders and 2–4px radii (`velvet_theme.tres`). Ornament devalues the figures and contradicts §4.8's "keep" list. |
| 11 | **A noisy battlefield.** Dense particles, weather, layered effects, a busy background competing with the figures. | §4.7's whole budget exists to prevent this. Negative space must be *composed*, not filled. |
| 12 | **Generic RPG inventory aesthetic.** Equipment slots, stat blocks, item grids, rarity frames, gold trim. | The 1G direction explicitly excludes it; `assets/portraits/README.md` exists to prevent it. |
| 13 | **Procedural placeholder artwork.** Recoloured pack sprites, mirrored stock assets, "temporary" art that ships. | `ART_INTAKE_AUDIT.md` established the packs are unusable. Recolouring them does not make them ours. **1H art is original.** |
| 14 | **Random gothic symbols with no visual purpose.** Cryptic sigils, alchemical marks, occult glyphs used as decoration. | Ornament without function is noise. The one symbol in the game — the broken seal (§2.6) — carries the contract theme. Every future symbol must earn its place the way it did. |
| 15 | **Screen-space glitch on characters.** RGB split, scanlines, chromatic aberration, noise overlay. | Reads as a post-process filter over hand-illustrated art, not as a property of the world. Corruption belongs in the drawing (§2.5). |
| 16 | **Figures out-detailing the card art.** Fine fabric weave, individual hair strands, texture noise at full resolution. | The hand is the player's primary read (§3.6). Figures lose to cards. |
| 17 | **Baked backgrounds in character PNGs.** An opaque field behind a figure. | Breaks §4.5's value hierarchy, prevents rim lighting, prevents the hit-flash. Alpha is mandatory (§5.1). |
| 18 | **Art inside the playtest safe area.** Anything inside the 16/12/16/14 margins asserted by `playtest_1c.gd`. | Layout assertion failures, and clipped art. |

### 8.3 Process failures

| # | Failure | Why it is fatal |
| - | ------- | --------------- |
| 19 | **Claiming an asset exists when it does not.** | §0.3 is the honesty check. Every entry in §5 is marked as not existing. |
| 20 | **Redrawing working 1G art for consistency's sake.** The card SVGs, the theme, the hairline frames are correct. | §6 and §4.8 identify them as the standard. "Consistent" is not a reason to replace correct work. |
| 21 | **Improvising art direction per asset.** A new palette, a new motif, a new crop convention for one file. | The entire purpose of this document. |
| 22 | **Deleting the code-drawn fallbacks.** | `StageOrnament` and `BackdropOrnament` are the baseline composition (§4.8) and the playtest harness asserts against the current geometry. |

---

## 9. SECTION 9 — ART PIPELINE

The goal is that the next piece of art produced is not a re-improvisation.

### 9.1 Character pipeline

**Stage 0 — specification conformance (before any drawing).**
Confirm the target file, resolution, alpha requirement, and pose from §5.
Confirm which of §1/§2 applies. Write down the §5.3/§5.4/§5.5 classification.

**Stage 1 — concept.**
Silhouette first, in solid black, at 120px. Must pass the §1.2 or §2.2
silhouette test *before* any interior detail. Deliverable: one black shape on
`#0c0b10`.

**Stage 2 — value block-in.**
Three values only: ground, mid, light (§1.5 or §2.4). No colour, no detail.
Confirms §4.9's value hierarchy holds before hue is committed.

**Stage 3 — final illustration.**
Palette, then detail, then corruption devices (§2.5) last. Detail budget
governed by §1.7's readability requirements, not by enthusiasm.

**Stage 4 — portrait crop.**
Derive the bust from the approved full-body, do not draw it separately. Reuse
§1.9/§2.8: three-quarter turn toward the opponent, 70–80% panel fill, 12%
margins, bottom-anchored composition to match `portrait_frame.gd:38`.

**Stage 5 — combat integration.**
Drop E1/E2 at their `assets/portraits/` paths — no code change. For O2/O3 and
anything in §5.5, this is a scene change and must be validated against
`playtest_1c.gd` in the same step.

**Stage 6 — verification at 1280x720.** The gate is §9.6.

### 9.2 Card pipeline

**Stage 0** — confirm the card's mechanical identity, since the art must serve
it (§6.4 rule 3: one idea).
**Stage 1** — thumbnail at 140x186, greyscale. Does the idea read?
**Stage 2** — 256x180 SVG, one dominant accent, flat vector.
**Stage 3** — palette comment on line 2 (§6.4 rule 2).
**Stage 4** — verify at well size, and verify against the unplayable
`modulate` state (§6.4 rule 10).
**Stage 5** — add to `CardView.CARD_ART` (`card_view.gd:22-28`). The
`CardSigil` fallback covers a missing entry, so a new card without art is
valid, not broken.

### 9.3 Map art pipeline

**Stage 0** — confirm the map's information design first. Node shapes encode
meaning (§7.5); art cannot be drawn before the shape language is settled.
**Stage 1** — environment value study at 1280x720, greyscale. Must be
indistinguishable from §4.5's battlefield environment in value range.
**Stage 2** — node icons at 128x128, shape-first, 8-type ceiling.
**Stage 3** — contact sheet: every node and the two character busts at true
relative scale (§7.7).
**Stage 4** — verify no shared silhouette class between nodes and characters.

### 9.4 Verification checklist

Run against every character, portrait, and environment asset.

| # | Check | Method |
| - | ----- | ------ |
| 1 | Correct resolution per §5 | File dimensions |
| 2 | Alpha present, no baked background | File inspection |
| 3 | ≥2 value steps above its background | Greyscale conversion |
| 4 | Reads at target display size | View at 100% of 1280x720 |
| 5 | Reads in greyscale | Desaturate |
| 6 | Survives a 40% crimson wash | Overlay `Color(0.937, 0.278, 0.38, 0.4)` |
| 7 | Within the 16/12/16/14 safe area | `playtest_1c.gd` |
| 8 | Silhouette distinct from the other principal | Solid-black 120px compare |
| 9 | Palette is entirely within §1.5/§2.4 | Sample every colour |
| 10 | No colour from outside the family | Sample every colour |

### 9.5 In-engine verification

Existing tooling, already in the repo:

- `scripts/playtest_1c.gd` — 55 geometry and interaction checks. Must stay at
  zero issues. Any art that changes layout is validated here in the same step.
- `scripts/verify_milestone_1b.gd` — 43 rules checks. Must stay at zero
  failures. Art must never affect it; a failure here means something was
  touched that should not have been.
- `scripts/screenshot_combat.gd` — captures
  `.tools/screenshot_combat_720.png` at a real 1280x720. The final gate for
  any art that reaches the screen.

Run:
```
Godot . --resolution 1280x720 --script res://scripts/playtest_1c.gd
Godot . --resolution 1280x720 --script res://scripts/verify_milestone_1b.gd
Godot . --resolution 1280x720 --script res://scripts/screenshot_combat.gd
```

### 9.6 The greyscale gate

**Every character and environment asset must pass a greyscale test before
acceptance.** Convert to greyscale and confirm the subject is still identifiable
from value structure alone.

This is the most important single check in the pipeline, and it exists for a
specific reason: the battlefield is near-black, the palette is narrow, and the
HUD already assigns meaning to two accent hues. A figure that depends on hue to
be understood will fail on a dimmed display, in a colour-blind player's view,
or the moment a corruption effect desaturates it. Value structure is the only
reliable carrier of readability in this game's visual language.

---

## 10. Status

This document is a specification. At the time of writing:

- **No art described here has been produced.**
- **No project file has been modified.** `scripts/combat_state.gd`,
  `scripts/combat_ui.gd`, `scripts/card_view.gd`, `scripts/portrait_frame.gd`,
  `scripts/stage_ornament.gd`, `scripts/backdrop_ornament.gd`,
  `ui/velvet_theme.tres`, `scenes/Combat.tscn`, and `scenes/Main.tscn` are
  untouched.
- **The five card SVGs are untouched.**
- **No assets have been imported.** The reviewed font and image candidates in
  `ART_INTAKE_AUDIT.md` §8 remain unimported.
- **Two code-level defects were found and are documented, not fixed:**
  Finding A (§0.4, the non-rendering silhouette) and Finding B (§0.4, the wrong
  portrait dimensions in `assets/portraits/README.md`).

The next actionable step is the smallest one in this document: produce **E1** and
**E2** (§5.3), the two bust portraits, which land at existing paths and require
no code or scene change.
