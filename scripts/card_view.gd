class_name CardView
extends PanelContainer
## An elegant illustrated card: cost beside the name, type as a quiet overline,
## one large artwork, a single hairline, then value + description.
## State API (playable / unaffordable / resolving) unchanged.

signal pressed(card: Dictionary)

const VELVET := Color(0.937, 0.278, 0.38)
const VIOLET := Color(0.584, 0.4, 0.858)
const OFF_WHITE := Color(0.9, 0.88, 0.9)
const MUTED := Color(0.78, 0.74, 0.78)
const DEAD_TEXT := Color(0.353, 0.298, 0.353)
const BORDER := Color(0.42, 0.294, 0.396)
const SURFACE := Color(0.114, 0.082, 0.106)
const SURFACE_LIT := Color(0.157, 0.106, 0.137)
const DEAD_BORDER := Color(0.208, 0.169, 0.208)
const DEAD_SURFACE := Color(0.078, 0.059, 0.078)

## Card identity -> illustration asset. Missing/failed loads fall back to
## the code-drawn CardSigil automatically.
const CARD_ART := {
	"strike": "res://assets/cards/velvet_cut.svg",
	"heavy": "res://assets/cards/gilt_collapse.svg",
	"defend": "res://assets/cards/smoke_veneer.svg",
	"ledger": "res://assets/cards/bleed_the_ledger.svg",
	"ink": "res://assets/cards/contract_ink.svg",
}

var card_data: Dictionary

var _name_label: Label
var _type_label: Label
var _desc_label: Label
var _value_label: Label
var _cost_label: Label
var _well: PanelContainer
var _style: StyleBoxFlat
var _kind: String
var _playable := true
var _resolving := false

func _init(card: Dictionary) -> void:
	card_data = card
	_kind = str(card.get("kind", ""))
	custom_minimum_size = Vector2(140, 186)
	focus_mode = Control.FOCUS_NONE
	tooltip_text = "%s — %s" % [card.get("name", "?"), card.get("type", "?")]

	_style = StyleBoxFlat.new()
	add_theme_stylebox_override("panel", _style)
	_apply_style(SURFACE, BORDER, Color(VELVET, 0.1), 8)

	var root := VBoxContainer.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_theme_constant_override("separation", 6)
	add_child(root)

	# -- Header: cost + name on one line, type as a quiet overline beneath.
	var head := HBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_theme_constant_override("separation", 8)
	root.add_child(head)

	_cost_label = Label.new()
	_cost_label.text = str(card.get("cost", 0))
	_cost_label.add_theme_color_override("font_color", VELVET)
	_cost_label.add_theme_font_size_override("font_size", 22)
	head.add_child(_cost_label)

	var title_wrap := VBoxContainer.new()
	title_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_wrap.add_theme_constant_override("separation", 1)
	head.add_child(title_wrap)

	_name_label = Label.new()
	_name_label.text = card.get("name", "???")
	_name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name_label.add_theme_color_override("font_color", OFF_WHITE)
	_name_label.add_theme_font_size_override("font_size", 16)
	title_wrap.add_child(_name_label)

	_type_label = Label.new()
	_type_label.text = str(card.get("type", "?")).to_upper()
	_type_label.add_theme_color_override("font_color", VIOLET)
	_type_label.add_theme_font_size_override("font_size", 10)
	title_wrap.add_child(_type_label)

	# -- Artwork: the largest surface of the card.
	_well = PanelContainer.new()
	var well_style := StyleBoxFlat.new()
	well_style.bg_color = Color(0.055, 0.039, 0.063)
	well_style.set_corner_radius_all(3)
	_well.add_theme_stylebox_override("panel", well_style)
	_well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_well.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_well.clip_contents = true
	root.add_child(_well)

	var well_stack := Control.new()
	well_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	well_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_well.add_child(well_stack)

	var art: TextureRect = null
	if CARD_ART.has(_kind):
		var tex: Texture2D = load(CARD_ART[_kind])
		if tex != null:
			art = TextureRect.new()
			art.texture = tex
			art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			art.set_anchors_preset(Control.PRESET_FULL_RECT)
			art.mouse_filter = Control.MOUSE_FILTER_IGNORE
			well_stack.add_child(art)
	if art == null:
		var sigil := CardSigil.new(_kind)
		sigil.set_anchors_preset(Control.PRESET_FULL_RECT)
		well_stack.add_child(sigil)

	# -- One hairline, then value and description. No nested boxes.
	var rule := ColorRect.new()
	rule.color = Color(0.42, 0.294, 0.396, 0.55)
	rule.custom_minimum_size = Vector2(0, 1)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(rule)

	_value_label = Label.new()
	_value_label.text = _extract_value(card)
	_value_label.add_theme_color_override("font_color", VELVET)
	_value_label.add_theme_font_size_override("font_size", 17)
	root.add_child(_value_label)

	_desc_label = Label.new()
	_desc_label.text = card.get("text", "")
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.add_theme_color_override("font_color", MUTED)
	_desc_label.add_theme_font_size_override("font_size", 12)
	root.add_child(_desc_label)

	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))
	_apply_text_state(true)

func _extract_value(card: Dictionary) -> String:
	# Prototype-level: surface the primary number from the card text.
	var text := str(card.get("text", ""))
	var words := text.split(" ")
	for w in words:
		if w.length() > 0 and w[0] >= "0" and w[0] <= "9":
			var cleaned := ""
			for ch in w:
				if ch >= "0" and ch <= "9":
					cleaned += ch
				else:
					break
			if not cleaned.is_empty():
				return cleaned
	return "—"

func _apply_style(bg: Color, border: Color, glow: Color, glow_size: int) -> void:
	_style.bg_color = bg
	_style.set_border_width_all(1)
	_style.border_color = border
	_style.set_corner_radius_all(4)
	_style.content_margin_left = 10
	_style.content_margin_right = 10
	_style.content_margin_top = 10
	_style.content_margin_bottom = 10
	_style.shadow_color = glow
	_style.shadow_size = glow_size

func _apply_text_state(playable: bool) -> void:
	var name_c := OFF_WHITE if playable else DEAD_TEXT
	var type_c := VIOLET if playable else DEAD_TEXT
	var desc_c := MUTED if playable else DEAD_TEXT
	_name_label.add_theme_color_override("font_color", name_c)
	_type_label.add_theme_color_override("font_color", type_c)
	_desc_label.add_theme_color_override("font_color", desc_c)
	_value_label.add_theme_color_override("font_color", VELVET if playable else DEAD_TEXT)
	_cost_label.add_theme_color_override("font_color", VELVET if playable else DEAD_TEXT)

func _apply_playable_style(playable: bool) -> void:
	_playable = playable
	if _resolving:
		return
	if playable:
		_apply_style(SURFACE, BORDER, Color(VELVET, 0.1), 8)
	else:
		_apply_style(DEAD_SURFACE, DEAD_BORDER, Color(0, 0, 0, 0), 0)
	_apply_text_state(playable)
	modulate = Color.WHITE if playable else Color(0.78, 0.74, 0.78)
	queue_redraw()

func set_state(playable: bool, resolving := false) -> void:
	_resolving = resolving
	if resolving:
		_apply_style(Color(0.29, 0.078, 0.125), VELVET, Color(VELVET, 0.55), 16)
		modulate = Color.WHITE
		queue_redraw()
	else:
		_apply_playable_style(playable)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(card_data)

func _on_hover(entered: bool) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", -10.0 if entered else 0.0, 0.12)
	if entered:
		if _resolving:
			return
		if _playable:
			_apply_style(SURFACE_LIT, VELVET, Color(VELVET, 0.3), 10)
		else:
			_apply_style(DEAD_SURFACE, DEAD_BORDER, Color(0, 0, 0, 0), 0)
	else:
		_apply_playable_style(_playable)
