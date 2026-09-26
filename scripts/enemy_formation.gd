class_name EnemyFormation
extends RefCounted
## Pure layout calculation for enemy presentation slots.
##
## Given a count (1, 2, or 3) this returns the rects for that many enemy
## presentation slots plus the matching HP-bar minimum width and name font size.
## It owns no nodes, touches no combat state, and loads no art - it only answers
## "where do the slots go and how big are they".
##
## The presentation layer (combat_ui.gd) applies the result. Multi-enemy combat
## can later drive the same function with a real count.

## --- THE COMPOSITION RULE ---------------------------------------------------
##
## The enemy formation is centred on the midpoint of the ENEMY-SIDE COMBAT
## REGION, not on the midpoint of the 1280px viewport.
##
## The region begins immediately after the protected player-side composition
## (the player portrait/identity stack and the Signatory's clearance boundary)
## and runs to the right screen edge.
##
## This is an intentional composition decision, not a workaround. The player
## stack and the Signatory own the left and centre of the frame, and both are
## protected: the player stack is not moved or shrunk, and the design
## resolution stays at 1280x720. Centring the formation on the viewport
## midpoint would require displacing one of them. So the enemy side is composed
## against its own region, and the resulting asymmetry between the player side
## and the enemy side is the intended read: the player is framed by the corner
## and the figure, the enemy side is a ranked bank of panels.
##
## Within the region, slots are distributed evenly: the group exactly fills the
## region width, so the formation's bounding box is centred on the region
## midpoint by construction rather than by a hand-tuned offset.
##
## A count of 1 is the one deliberate exception to "fills the region": the
## single panel stays right-anchored to the region edge, preserving the
## established single-duel composition exactly. Even distribution is undefined
## for a single item, and preserving that composition takes precedence.

## --- battlefield frame -----------------------------------------------------

const SCREEN_W := 1280.0
const SCREEN_H := 720.0
const HORIZON_Y := 396.0
const MARGIN := 44.0
const GAP := 16.0

## --- shared vertical band (identical for every slot) ------------------------
## Bottom of the band is 392.0, which clears HORIZON_Y by 4px. Every portrait,
## identity and intent group shares this band, so a multi-slot formation stays
## on one row above the horizon.

const PORTRAIT_TOP := 56.0
const PORTRAIT_H := 250.0
const IDENTITY_TOP := 312.0
const IDENTITY_H := 54.0
const INTENT_TOP := 370.0
const INTENT_H := 22.0

## --- protected player-side composition --------------------------------------
## Both of these are cleared by every slot. They are not negotiable: the player
## stack must not be moved or shrunk, and the Signatory must keep her column.

const SIGNATORY_LEFT := 462.0
const SIGNATORY_RIGHT := 758.0
const PLAYER_STACK_RIGHT := 284.0

## --- the enemy-side combat region -------------------------------------------
## Clears the Signatory by GAP, runs to the right screen edge minus MARGIN.
## At the current composition this is x 774.0 -> 1236.0, 462.0 wide.

const REGION_LEFT := SIGNATORY_RIGHT + GAP
const REGION_RIGHT := SCREEN_W - MARGIN

## --- slot metrics -----------------------------------------------------------
## A count of 1 keeps the original 300px panel. Higher counts divide the region
## so the group fills it exactly: slot width shrinks rather than overlapping the
## Signatory, the player stack, or a neighbouring slot.

const WIDE_SLOT_W := 300.0
const MAX_SLOTS := 3

## Room reserved in a slot for the HP numeric readout and its separation.
const HP_TEXT_ALLOWANCE := 70.0
const HP_BAR_MAX := 220.0

## Name label sizes: full size at full width, scaled down but never below the
## 10px legibility floor the 1C playtest enforces.
const NAME_FONT_MAX := 20.0
const NAME_FONT_MIN := 10.0
const FONT_FLOOR := 10.0


## The enemy-side combat region. Midpoint of this rect is the formation's
## centre of composition.
static func region() -> Rect2:
	return Rect2(REGION_LEFT, PORTRAIT_TOP, REGION_RIGHT - REGION_LEFT, PORTRAIT_H)


## Midpoint of the enemy-side region: the x the formation is centred on.
static func region_center_x() -> float:
	return (REGION_LEFT + REGION_RIGHT) * 0.5


static func slot_width(count: int) -> float:
	var n := clampi(count, 1, MAX_SLOTS)
	if n == 1:
		# Preserve the established single-duel panel exactly.
		return WIDE_SLOT_W
	# Even distribution: n slots and n-1 gaps exactly fill the region.
	return (region().size.x - (n - 1) * GAP) / float(n)


static func hp_bar_width(count: int) -> float:
	return minf(HP_BAR_MAX, slot_width(count) - HP_TEXT_ALLOWANCE)


static func name_font_size(count: int) -> float:
	return maxf(NAME_FONT_MIN, NAME_FONT_MAX * slot_width(count) / WIDE_SLOT_W)


## Full formation for a count. Returns one Dictionary per slot with keys
## `portrait`, `identity`, `intent` (Rect2), `hp_bar_width` (float) and
## `name_font_size` (int), ordered left to right.
##
## For counts above 1 the group exactly fills the region, so the formation is
## centred on the region midpoint. For a count of 1 the single panel is
## right-anchored to the region edge.
static func layout(count: int) -> Array:
	var n := clampi(count, 1, MAX_SLOTS)
	var reg := region()
	var w := slot_width(n)
	var hp := hp_bar_width(n)
	var name_size := int(round(name_font_size(n)))

	var group_w := n * w + (n - 1) * GAP
	var x0 := reg.position.x
	if n == 1:
		# Right-anchored: preserves the existing single-duel composition.
		x0 = reg.position.x + reg.size.x - group_w

	var out: Array = []
	for i in n:
		var x := x0 + i * (w + GAP)
		out.append({
			"portrait": Rect2(x, PORTRAIT_TOP, w, PORTRAIT_H),
			"identity": Rect2(x, IDENTITY_TOP, w, IDENTITY_H),
			"intent": Rect2(x, INTENT_TOP, w, INTENT_H),
			"hp_bar_width": hp,
			"name_font_size": name_size,
		})
	return out


## Bounding box of a formation, for verification and for composing the
## Signatory relative to it.
static func bounds(count: int) -> Rect2:
	var slots := layout(count)
	if slots.is_empty():
		return Rect2()
	var r: Rect2 = slots[0]["portrait"]
	for s in slots:
		r = r.merge(s["portrait"])
	return r


## True when a formation keeps its whole band above the horizon spine.
static func clears_horizon(count: int) -> bool:
	return INTENT_TOP + INTENT_H <= HORIZON_Y


## True when a formation is composed against the enemy-side region as intended:
## counts above 1 are centred on the region midpoint, and a count of 1 is
## right-anchored to the region edge.
static func composed_against_region(count: int) -> bool:
	var n := clampi(count, 1, MAX_SLOTS)
	var b := bounds(n)
	if n == 1:
		return absf(b.end.x - REGION_RIGHT) < 0.5
	return absf((b.position.x + b.end.x) * 0.5 - region_center_x()) < 0.5
