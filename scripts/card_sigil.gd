class_name CardSigil
extends Control
## Abstract gothic sigil for the card art well, chosen by card kind.
## Restraint-level: thin linework, one accent, ink-dark strokes.

const CRIMSON := Color(0.867, 0.208, 0.31)
const BURGUNDY := Color(0.549, 0.102, 0.184)
const VIOLET := Color(0.584, 0.4, 0.858)
const PALE := Color(0.71, 0.639, 0.705)

var _kind: String

func _init(kind: String) -> void:
	_kind = kind
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

func _draw() -> void:
	var s := size
	if s.x < 10.0 or s.y < 10.0:
		return
	var c := s * 0.5
	match _kind:
		PrototypeDeck.STRIKE:
			_draw_blade(c, s)
		PrototypeDeck.HEAVY:
			_draw_blade(c, s, 1.45)
		PrototypeDeck.DEFEND:
			_draw_veil(c, s)
		PrototypeDeck.LEDGER:
			_draw_seal(c, s)
		PrototypeDeck.INK:
			_draw_quill(c, s)
		_:
			_draw_veil(c, s)

func _blade_angle(c: Vector2, scale: float) -> void:
	var l := 34.0 * scale
	var dir := Vector2(0.62, -0.78).normalized()
	var tip := c + dir * l
	var tail := c - dir * (l * 0.75)
	# Blade line with a soft under-glow.
	draw_line(tail, tip, Color(CRIMSON, 0.16), 5.0 * scale)
	draw_line(tail, tip, PALE, 1.4)
	# Guard: a short perpendicular tick.
	var perp := Vector2(-dir.y, dir.x)
	draw_line(tail + perp * 6.0 * scale, tail - perp * 6.0 * scale, BURGUNDY, 1.6)
	# Ink drop at the tip.
	draw_circle(tip, 1.6 * scale, CRIMSON)

func _draw_blade(c: Vector2, s: Vector2, scale: float = 1.0) -> void:
	_blade_angle(c, scale)

func _draw_veil(c: Vector2, s: Vector2) -> void:
	# Draped veil: three descending arcs with a violet bloom at the clasp.
	for i in 3:
		var r := 16.0 + i * 7.0
		draw_arc(c + Vector2(0, -4 + i * 5), r, PI * 0.12, PI * 0.88, 24, Color(PALE, 0.35 - i * 0.08), 1.0, true)
	draw_circle(c + Vector2(0, 8), 2.2, VIOLET)
	draw_circle(c + Vector2(0, 8), 5.0, Color(VIOLET, 0.18))

func _draw_seal(c: Vector2, s: Vector2) -> void:
	# Contract seal: double ring, inner wax disc, four drips.
	draw_arc(c, 15.0, 0, TAU, 40, Color(BURGUNDY, 0.9), 1.0, true)
	draw_arc(c, 19.0, 0, TAU, 40, Color(BURGUNDY, 0.35), 1.0, true)
	draw_circle(c, 10.0, Color(BURGUNDY, 0.28))
	draw_circle(c, 10.0, Color(0, 0, 0, 0))
	# Ring notches at the cardinal points (the "fine print").
	for a: float in [0.0, PI * 0.5, PI, PI * 1.5]:
		var d := Vector2(cos(a), sin(a))
		draw_line(c + d * 15.0, c + d * 21.0, Color(BURGUNDY, 0.7), 1.0)
	# Drips.
	draw_line(c + Vector2(-4, 10), c + Vector2(-4, 15), Color(BURGUNDY, 0.55), 1.0)
	draw_line(c + Vector2(5, 9), c + Vector2(5, 13), Color(BURGUNDY, 0.45), 1.0)

func _draw_quill(c: Vector2, s: Vector2) -> void:
	# Ink quill: a violet feather stroke and a settling drop.
	var dir := Vector2(-0.5, 0.86).normalized()
	var base := c + Vector2(10, 14)
	var tip := base + dir * -34.0
	draw_line(base, tip, Color(VIOLET, 0.2), 4.5)
	draw_line(base, tip, PALE, 1.2)
	# Barb strokes along the shaft.
	for t: float in [0.3, 0.5, 0.7]:
		var p := base + (tip - base) * t
		var side := Vector2(-dir.y, dir.x)
		draw_line(p, p + side * 7.0, Color(VIOLET, 0.5), 0.9)
	draw_circle(base + Vector2(3, 2), 1.7, CRIMSON)
