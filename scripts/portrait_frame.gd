class_name PortraitFrame
extends Control
## Rectangular illustrated-portrait composition: dark vignette, restrained
## hairline frame with accent corner ticks, ground shadow, and a silhouette
## fallback. A real portrait_texture, when set, becomes the focal artwork.

@export_enum("enemy", "player") var mode := "enemy"
@export var portrait_texture: Texture2D

var _flash := 0.0
var _impact := 0.0

func set_hit_flash(strength: float) -> void:
	_flash = clampf(strength, 0.0, 1.0)
	queue_redraw()

func set_impact(strength: float) -> void:
	_impact = clampf(strength, 0.0, 1.0)
	queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var sz: Vector2 = size
	if sz == Vector2.ZERO:
		return

	# Interior vignette: deep black drifting toward the frame edges.
	draw_rect(Rect2(Vector2.ZERO, sz), Color(0.055, 0.043, 0.06))
	draw_rect(Rect2(Vector2.ZERO, sz), Color(0.008, 0.004, 0.012, 0.55))

	# Real portrait texture: the intended focal artwork.
	if portrait_texture != null:
		var tex_size := portrait_texture.get_size()
		var fit: float = minf(sz.x / tex_size.x, sz.y / tex_size.y)
		var draw_size := tex_size * fit
		var draw_pos := Vector2((sz.x - draw_size.x) * 0.5, sz.y - draw_size.y)
		draw_texture_rect(portrait_texture, Rect2(draw_pos, draw_size), false)
	else:
		_draw_fallback_figure(sz)

	# Ground shadow line: anchors the figure inside the frame.
	var floor_y := sz.y - 8.0
	var shadow := Color(0.867, 0.208, 0.31, 0.16) if mode == "enemy" else Color(0.584, 0.4, 0.858, 0.12)
	draw_line(Vector2(14, floor_y), Vector2(sz.x - 14, floor_y), shadow, 2.0)

	# Hairline frame with a few accent corner ticks. Nothing more.
	var frame := Rect2(Vector2(0.5, 0.5), sz - Vector2(1, 1))
	var line := Color(0.42, 0.294, 0.396, 0.8)
	draw_rect(frame, line, false, 1.0)
	var accent := Color(0.867, 0.208, 0.31) if mode == "enemy" else Color(0.584, 0.4, 0.858)
	var t := 12.0
	var tl := Vector2(0.5, 0.5)
	var tr := Vector2(sz.x - 0.5, 0.5)
	var bl := Vector2(0.5, sz.y - 0.5)
	var br := Vector2(sz.x - 0.5, sz.y - 0.5)
	draw_line(tl, tl + Vector2(t, 0), accent, 1.6)
	draw_line(tl, tl + Vector2(0, t), accent, 1.6)
	draw_line(br, br - Vector2(t, 0), accent, 1.6)
	draw_line(br, br - Vector2(0, t), accent, 1.6)

	# Damage feedback: full-frame wash.
	if _flash > 0.01:
		draw_rect(Rect2(Vector2.ZERO, sz), Color(0.937, 0.278, 0.38, _flash * 0.4))

func _draw_fallback_figure(sz: Vector2) -> void:
	# Temporary silhouette fallback: a cloaked bust composed for a portrait
	# crop — head, shoulders, collar. Deliberately simple, frame fills with art.
	var cx := sz.x * 0.5
	var base := sz.y * 0.92
	var head_r: float = minf(sz.x, sz.y) * 0.13
	var head := Vector2(cx, sz.y * 0.36)
	# Neck + shoulders mass.
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - head_r * 0.55, head.y + head_r * 0.7),
		Vector2(cx + head_r * 0.55, head.y + head_r * 0.7),
		Vector2(cx + sz.x * 0.30, base),
		Vector2(cx - sz.x * 0.30, base),
	]), Color(0.024, 0.016, 0.035))
	# Head.
	draw_circle(head, head_r, Color(0.024, 0.016, 0.035))
	# Rim light on the mode accent side: a single quiet edge stroke.
	var accent := Color(0.867, 0.208, 0.31, 0.5) if mode == "enemy" else Color(0.584, 0.4, 0.858, 0.4)
	var side := 1.0 if mode == "enemy" else -1.0
	draw_line(Vector2(cx + side * sz.x * 0.30, base), Vector2(cx + side * head_r * 0.6, head.y + head_r * 0.75), accent, 1.2)
	if mode == "enemy":
		# Two dim eyes in the hood shadow.
		var eye_y := head.y - head_r * 0.1
		draw_circle(Vector2(cx - head_r * 0.35, eye_y), 1.8, Color(0.867, 0.208, 0.31, 0.8))
		draw_circle(Vector2(cx + head_r * 0.35, eye_y), 1.8, Color(0.867, 0.208, 0.31, 0.8))
	else:
		# Blade line across the shoulder.
		draw_line(Vector2(cx - sz.x * 0.18, sz.y * 0.62), Vector2(cx + sz.x * 0.26, sz.y * 0.5), Color(0.71, 0.639, 0.705, 0.45), 1.1)
