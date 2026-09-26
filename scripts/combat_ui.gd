extends Control
## Combat UI controller. Presentation only: reads CombatState, pushes values
## into labels, and orchestrates the visible turn sequence.

const VELVET := Color(0.937, 0.278, 0.38)
const VIOLET := Color(0.584, 0.4, 0.858)
const MUTED := Color(0.549, 0.486, 0.549)
const FAINT := Color(0.353, 0.298, 0.353)

@onready var _turn_label: Label = %TurnLabel
@onready var _end_button: Button = %EndTurnButton
@onready var _hand: HBoxContainer = %Hand
@onready var _player_hp_bar: ProgressBar = %PlayerHPBar
@onready var _player_hp_text: Label = %PlayerHPText
@onready var _block_label: Label = %BlockLabel
@onready var _intent_label: Label = %IntentLabel
@onready var _enemy_hp_bar: ProgressBar = %EnemyHPBar
@onready var _enemy_hp_text: Label = %EnemyHPText
@onready var _enemy_name_label: Label = %EnemyNameLabel
@onready var _energy_number: Label = %EnergyNumber
@onready var _draw_count: Label = %DrawCount
@onready var _discard_count: Label = %DiscardCount
@onready var _overlay_dim: ColorRect = %OverlayDim
@onready var _outcome_title: Label = %OutcomeTitle
@onready var _outcome_detail: Label = %OutcomeDetail
@onready var _restart_button: Button = %RestartButton

const CARD_VIEW := preload("res://scripts/card_view.gd")
const PORTRAIT := preload("res://scripts/portrait_frame.gd")

var state: CombatState
var _card_views: Array = []
var _enemy_acting := false
var _player_portrait: PortraitFrame
var _player_home: Vector2

const PORTRAIT_TEXTURES := {
	"%EnemyPortrait": "res://assets/portraits/undersigned.png",
	"%PlayerPortrait": "res://assets/portraits/protagonist.png",
}

func _ready() -> void:
	_end_button.pressed.connect(_on_end_turn_pressed)
	_restart_button.pressed.connect(_restart)
	_player_portrait = get_node_or_null("%PlayerPortrait")
	if _player_portrait != null:
		_player_home = _player_portrait.position
	_drop_in_portraits()
	_start_state()

func _drop_in_portraits() -> void:
	# Art seam: if a real portrait texture exists, hand it to the frame; the
	# code-drawn silhouette remains the fallback. Missing files are silent.
	for slot in PORTRAIT_TEXTURES:
		var portrait: PortraitFrame = get_node_or_null(slot)
		if portrait == null or portrait.portrait_texture != null:
			continue
		var asset_path: String = PORTRAIT_TEXTURES[slot]
		if ResourceLoader.exists(asset_path):
			portrait.portrait_texture = load(asset_path)

func _start_state() -> void:
	state = CombatState.new(20260925)
	state.turn_changed.connect(_refresh_turn_state)
	state.state_changed.connect(_refresh_all)
	_build_hand()
	_refresh_all()

func _restart() -> void:
	if state.turn_changed.is_connected(_refresh_turn_state):
		state.turn_changed.disconnect(_refresh_turn_state)
	if state.state_changed.is_connected(_refresh_all):
		state.state_changed.disconnect(_refresh_all)
	state = CombatState.new(20260925)
	state.turn_changed.connect(_refresh_turn_state)
	state.state_changed.connect(_refresh_all)
	_build_hand()
	_refresh_all()

func _build_hand() -> void:
	for child in _hand.get_children():
		child.queue_free()
	_card_views.clear()
	for card in state.hand:
		var view: CardView = CARD_VIEW.new(card)
		view.pressed.connect(_on_card_pressed)
		_hand.add_child(view)
		_card_views.append(view)

func _on_card_pressed(card: Dictionary) -> void:
	if not state.can_play(card) or _enemy_acting:
		return
	_play_card(card)

func _play_card(card: Dictionary) -> void:
	var turn := state.turn_number
	var view := _view_for(card)
	if view:
		view.set_state(false, true)
		await get_tree().create_timer(0.12).timeout
	if turn != state.turn_number or view == null:
		return
	state.play_card(card)
	_build_hand()
	_refresh_all()
	_pulse_hud(card)

func _view_for(card: Dictionary) -> CardView:
	for view in _card_views:
		if view.card_data == card:
			return view
	return null

func _refresh_all() -> void:
	_player_hp_bar.max_value = state.player_max_hp
	_player_hp_bar.value = state.player_hp
	_player_hp_text.text = "%d / %d" % [state.player_hp, state.player_max_hp]
	_block_label.text = "BLOCK %d" % state.player_block if state.player_block > 0 else ""

	_enemy_name_label.text = state.enemy_name
	_enemy_hp_bar.max_value = state.enemy_max_hp
	_enemy_hp_bar.value = state.enemy_hp
	_enemy_hp_text.text = "%d / %d" % [state.enemy_hp, state.enemy_max_hp]
	_intent_label.text = "STRIKE — %d" % state.enemy_intent

	_energy_number.text = "%d / %d" % [state.energy, state.max_energy]
	_draw_count.text = str(state.draw_pile.size())
	_discard_count.text = str(state.discard_pile.size())

	_end_button.disabled = _enemy_acting or state.is_over() or not state.is_player_turn()
	_update_playable()
	_update_overlay()

func _update_playable() -> void:
	for view in _card_views:
		view.set_state(state.can_play(view.card_data), false)

func _pulse_hud(card: Dictionary) -> void:
	# Brief emphasis on whichever readout the played card touched.
	var kind: String = str(card.get("kind", ""))
	var targets: Array = []
	if kind in [PrototypeDeck.STRIKE, PrototypeDeck.HEAVY, PrototypeDeck.LEDGER]:
		targets = [%EnemyHPText, %EnemyHPBar]
		_flash_portrait("%EnemyPortrait")
	elif kind == PrototypeDeck.DEFEND:
		targets = [%BlockLabel]
		_flash_portrait("%PlayerPortrait")
	elif kind == PrototypeDeck.INK:
		targets = [%DrawCount]
	for t in targets:
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		if t is ProgressBar:
			tween.tween_property(t, "modulate", Color(1.6, 1.3, 1.4), 0.08)
		else:
			tween.tween_property(t, "modulate", Color(1.8, 1.45, 1.55), 0.08)
		tween.tween_property(t, "modulate", Color.WHITE, 0.3)
	var energy_tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	energy_tween.tween_property(%EnergyNumber, "modulate", Color(1.8, 1.45, 1.55), 0.08)
	energy_tween.tween_property(%EnergyNumber, "modulate", Color.WHITE, 0.3)

func _flash_portrait(silhouette_path: String) -> void:
	var portrait: PortraitFrame = get_node_or_null(silhouette_path)
	if portrait == null:
		return
	var tween := create_tween()
	tween.tween_method(portrait.set_hit_flash, 1.0, 0.0, 0.35)

func _update_overlay() -> void:
	if state.is_over():
		_fade_overlay()
		if state.phase == CombatState.Phase.VICTORY:
			_outcome_title.text = "THE CONTRACT CLOSES"
			_outcome_title.add_theme_color_override("font_color", VELVET)
			_outcome_detail.text = "The Undersigned signs in ruin."
		else:
			_outcome_title.text = "RUIN"
			_outcome_title.add_theme_color_override("font_color", VIOLET)
			_outcome_detail.text = "THE VELVET GOES DARK — YOUR DEBTS COME DUE"
	else:
		_overlay_dim.visible = false

func _fade_overlay() -> void:
	if _overlay_dim.visible:
		return
	_overlay_dim.visible = true
	_overlay_dim.modulate = Color(1, 1, 1, 0)
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_overlay_dim, "modulate:a", 1.0, 0.45)

func _on_end_turn_pressed() -> void:
	if state.is_player_turn() and not _enemy_acting and not state.is_over():
		var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(_end_button, "modulate", Color(0.55, 0.4, 0.5), 0.1)
		t.tween_property(_end_button, "modulate", Color.WHITE, 0.2)
		_run_enemy_turn()

func _run_enemy_turn() -> void:
	if _enemy_acting:
		return
	_enemy_acting = true
	_end_button.disabled = true
	state.end_player_turn()
	_refresh_all()

	_turn_label.text = "ENEMY TURN"
	_turn_label.add_theme_color_override("font_color", VIOLET)
	await get_tree().create_timer(0.5).timeout

	# Attack motion: a restrained lunge toward the player, then settle back.
	var enemy_portrait: PortraitFrame = get_node_or_null("%EnemyPortrait")
	if enemy_portrait != null:
		var home_y: float = enemy_portrait.position.y
		var lunge := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		lunge.tween_property(enemy_portrait, "position:y", home_y + 16.0, 0.14)
		lunge.tween_property(enemy_portrait, "position:y", home_y, 0.22)

	var result := state.begin_enemy_action()
	_refresh_all()
	if result["absorbed"] > 0:
		_flash_portrait("%PlayerPortrait")
	if result["absorbed"] > 0:
		_intent_label.text = "STRIKE — %d (%d ABSORBED BY BLOCK)" % [result["through"], result["absorbed"]]
	else:
		_intent_label.text = "STRIKE — %d" % result["through"]
	await get_tree().create_timer(0.6).timeout

	if result["through"] > 0:
		var shake := create_tween()
		shake.tween_method(func(v: float): _player_portrait.position.x = _player_home.x + v, 0.0, 4.0, 0.06)
		shake.tween_method(func(v: float): _player_portrait.position.x = _player_home.x - v, 4.0, 0.0, 0.06)
		_flash_portrait("%PlayerPortrait")
	if result["defeat"]:
		_enemy_acting = false
		_fade_overlay()
		_refresh_all()
		return

	state.begin_player_turn()
	_enemy_acting = false
	_build_hand()
	_refresh_all()

func _refresh_turn_state() -> void:
	if state.is_over():
		_turn_label.text = "COMBAT OVER"
		_turn_label.add_theme_color_override("font_color", FAINT)
	elif state.is_player_turn():
		_turn_label.text = "TURN %d — YOUR MOVE" % state.turn_number
		_turn_label.add_theme_color_override("font_color", VELVET)
	else:
		_turn_label.text = "TURN %d — ENEMY ACTING" % state.turn_number
		_turn_label.add_theme_color_override("font_color", VIOLET)
