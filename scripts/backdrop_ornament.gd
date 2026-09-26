class_name BackdropOrnament
extends Control
## Scene-level restraint: quiet hairline ticks in the four corners.
## Nothing else — the characters and cards carry the scene.

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _draw() -> void:
	var vp := size
	if vp == Vector2.ZERO:
		return
	var m := 14.0
	var faint := Color(0.298, 0.22, 0.278, 0.35)
	var corners := [
		[Vector2(m, m), Vector2(1, 1)],
		[Vector2(vp.x - m, m), Vector2(-1, 1)],
		[Vector2(vp.x - m, vp.y - m), Vector2(-1, -1)],
		[Vector2(m, vp.y - m), Vector2(1, -1)],
	]
	for c in corners:
		var p: Vector2 = c[0]
		var d: Vector2 = c[1]
		draw_line(p, p + Vector2(22.0 * d.x, 0), faint, 1.0)
		draw_line(p, p + Vector2(0, 22.0 * d.y), faint, 1.0)
