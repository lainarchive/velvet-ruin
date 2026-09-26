class_name StageOrnament
extends Control
## Battlefield atmosphere, minimal: a soft horizon band, one thin divider,
## a few tiny sigil marks. No circles, no rings, no glow lakes.

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _draw() -> void:
	var s := size
	if s.x < 10.0 or s.y < 10.0:
		return
	var cx := s.x * 0.5
	var horizon := s.y * 0.55

	# Soft atmospheric band above the horizon (flat translucent wash, not a blob).
	draw_rect(Rect2(0, horizon - 34.0, s.x, 34.0), Color(0.055, 0.043, 0.06, 0.30))
	# Thin horizon divider.
	draw_line(Vector2(46, horizon), Vector2(s.x - 46, horizon), Color(0.298, 0.22, 0.278, 0.45), 1.0)
	# A few tiny marks between the combatants: embers, not decoration.
	var marks := Color(0.867, 0.208, 0.31, 0.30)
	var marks_v := Color(0.584, 0.4, 0.858, 0.22)
	var pts := [
		[cx - 120.0, horizon - 22.0, 1.4, marks],
		[cx - 52.0, horizon + 14.0, 1.1, marks_v],
		[cx + 36.0, horizon - 30.0, 1.6, marks],
		[cx + 118.0, horizon + 10.0, 1.1, marks_v],
		[cx + 190.0, horizon - 16.0, 1.3, marks],
	]
	for p in pts:
		draw_circle(Vector2(p[0], p[1]), p[2], p[3])
