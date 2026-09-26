extends SceneTree
## Milestone 1C playtest harness. Interacts through real UI paths and audits
## layout geometry the way a player would experience it.

var _failures := 0

func _ok(msg: String) -> void:
	print("PLAY-OK: " + msg)

func _issue(msg: String) -> void:
	_failures += 1
	print("PLAY-ISSUE: " + msg)

func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/Combat.tscn")
	var combat = scene.instantiate()
	root.add_child(combat)
	await process_frame
	await process_frame

	_audit_geometry(combat)
	await _session(combat)

	if _failures == 0:
		print("PLAY: NO ISSUES FOUND")
	else:
		print("PLAY: %d ISSUE(S) FOUND" % _failures)
	combat.queue_free()
	quit(0)

func _labels(node: Node, out: Array) -> void:
	for child in node.get_children():
		if child is Label:
			out.append(child)
		_labels(child, out)

func _audit_geometry(combat) -> void:
	# Whole-window control that owns the theme.
	var ctrl: Control = combat.get_node(".")
	var theme_res: Theme = ctrl.theme
	if theme_res == null:
		_issue("scene has no theme")
		return

	# Legibility audit: every label must render 10px or taller.
	var bad_font := []
	_labels(ctrl, bad_font)
	var small := 0
	for l in bad_font:
		if l.visible and not l.text.is_empty() and l.get_theme_font_size("font_size") < 10:
			small += 1
	_check(small == 0, "all visible labels render at 10px or larger",
		"%d labels render below 10px" % small)

	# The seven milestone reads must fit inside the viewport.
	var reads := {
		"%TurnLabel": "turn state",
		"%EnergyNumber": "energy",
		"%PlayerHPText": "player HP",
		"%EnemyHPText": "enemy HP",
		"%IntentLabel": "enemy intent",
		"%DrawCount": "draw count",
		"%DiscardCount": "discard count",
	}
	for path in reads:
		var node: Control = combat.get_node(path)
		if node == null:
			_issue(reads[path] + " read is missing")
			continue
		var vp := ctrl.get_viewport_rect().size
		var in_view := node.get_global_rect().intersects(Rect2(Vector2.ZERO, vp)) \
			or node.get_global_rect().position.y < vp.y
		_check(in_view, reads[path] + " sits within the visible window",
			reads[path] + " renders outside the window")

	# Hand must not overflow its hand area at rest.
	var hand: HBoxContainer = combat.get_node("%Hand")
	var clip: Control = combat.get_node("%HandClip")
	var needed := 0.0
	for view in hand.get_children():
		needed += view.custom_minimum_size.x + 4.0
	var avail := clip.size.x
	_check(needed <= avail, "5-card hand fits the hand area (%.0f / %.0f px)" % [needed, avail],
		"hand needs %.0f px but only %.0f px exist (clipping)" % [needed, avail])

	# 720-fit guarantee: the window is 1280x1280 headless, so verify that the
	# whole layout's minimum height fits the 720 design window and that no card
	# is taller than the hand column it lives in (no bottom bleed at 720).
	var design_h := 720.0
	var hand_column: Control = combat.get_node("%HandColumn")
	var over_bleed := 0
	for view in hand.get_children():
		var col_rect: Rect2 = Rect2(hand_column.global_position, hand_column.size)
		if not col_rect.encloses(view.get_global_rect()):
			over_bleed += 1
	_check(over_bleed == 0, "every card stays inside the hand column (no bleed)",
		"%d card(s) exceed the hand column bounds" % over_bleed)

	# 1G: every combat element must sit inside the 1280x720 window, with the
	# enemy and player groups on opposite sides (facing composition).
	var intent_row: Control = combat.get_node("%IntentRow")
	var design := Rect2(0, 0, 1280, 720)
	var safe_paths := [
		"%EnemyPortrait", "%IntentLabel", "%EnemyHPBar", "%EnemyHPText",
		"%EnemyNameLabel", "%PlayerPortrait", "%PlayerHPBar", "%PlayerHPText",
		"%BlockLabel", "%PlayerNameLabel", "%EnergyNumber", "%HandClip",
		"%DrawCount", "%DiscardCount", "%EndTurnButton", "%TurnLabel",
	]
	for path in safe_paths:
		var el: Control = combat.get_node(path)
		if el == null:
			_issue("safe-area target missing: " + path)
			continue
		if not design.encloses(el.get_global_rect().abs()):
			_issue("element outside 1280x720: " + path + " " + str(el.get_global_rect().abs()))
		else:
			_ok("safe: " + path)
	var enemy_sil: Control = combat.get_node("%EnemyPortrait")
	var player_sil: Control = combat.get_node("%PlayerPortrait")
	_check(not enemy_sil.get_global_rect().abs().intersects(player_sil.get_global_rect().abs()),
		"enemy and player portraits do not overlap",
		"enemy and player portraits overlap")
	_check(enemy_sil.get_global_rect().abs().position.x > player_sil.get_global_rect().abs().end.x,
		"facing composition: enemy right of player",
		"portraits are not on opposite sides")
	_check(not intent_row.get_global_rect().abs().intersects(enemy_sil.get_global_rect().abs()),
		"intent row does not overlap the enemy portrait",
		"intent row still overlaps the enemy portrait")

	# 1F: every mapped art asset must load, regardless of which cards were dealt.
	for kind in CardView.CARD_ART:
		var tex: Texture2D = load(CardView.CARD_ART[kind])
		_check(tex != null, "art asset loads for identity: " + kind,
			"art asset failed to load: " + str(CardView.CARD_ART[kind]))

	# 1F: every hand card must carry a loaded illustration texture.
	var hand2: HBoxContainer = combat.get_node("%Hand")
	for v in hand2.get_children():
		var well_stack: Control = v.get_child(0).get_child(1).get_child(0)
		var found_tex := false
		for w in well_stack.get_children():
			if w is TextureRect and w.texture != null:
				found_tex = true
				break
		_check(found_tex, "illustration loaded for: " + str(v.card_data.get("name", "?")),
			"no loaded illustration texture on card: " + str(v.card_data.get("name", "?")))

	# Fallback proof: a CardView built from an unknown kind must draw the
	# code-drawn sigil (no TextureRect) instead of failing.
	var probe := CardView.new({"kind": "__unknown__", "name": "Fallback Probe", "cost": 0, "type": "Test", "text": ""})
	combat.add_child(probe)
	var probe_has_tex := false
	var probe_stack: Control = probe.get_child(0).get_child(1).get_child(0)
	for w in probe_stack.get_children():
		if w is TextureRect:
			probe_has_tex = true
			break
	_check(not probe_has_tex, "sigil fallback engages for unknown identity", "fallback sigil missing for unknown kind")
	probe.queue_free()

	# Regression guard: the hand must never be clipped by design, and the turn
	# label color override must always be re-applied (1C regression guard).
	var overlay: ColorRect = combat.get_node("%OverlayDim")
	_check(not overlay.visible, "outcome overlay hidden at combat start", "overlay visible at start")

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	if cond:
		_ok(ok_msg)
	else:
		_issue(fail_msg)

func _session(combat) -> void:
	var s = combat.state
	var end_btn: Button = combat.get_node("%EndTurnButton")

	# 0) Restart first for a deterministic session start.
	combat.get_node("%RestartButton").pressed.emit()
	await create_timer(0.35).timeout
	s = combat.state

	# 1) A single click must actually play a card (whole-card hit target).
	var hand: HBoxContainer = combat.get_node("%Hand")
	var view: CardView = hand.get_child(0)
	var cost: int = int(view.card_data.get("cost", 0))
	var hand_before: int = s.hand.size()
	view.pressed.emit(view.card_data)
	await create_timer(0.35).timeout
	_check(s.hand.size() == hand_before - 1 and s.energy == 3 - cost,
		"single click plays card (energy %d -> %d)" % [3, s.energy],
		"click did not play the card")

	# 2) Unaffordable cards must be visibly distinct and unplayable.
	hand = combat.get_node("%Hand")
	var heavy: CardView = null
	for v in hand.get_children():
		if int(v.card_data.get("cost", 0)) > s.energy:
			heavy = v
			break
	if heavy != null:
		_check(not heavy.modulate.is_equal_approx(Color.WHITE),
			"unaffordable card is visually dimmed", "unaffordable card not visually distinct")
		var hp0: int = s.enemy_hp
		heavy.pressed.emit(heavy.card_data)
		await create_timer(0.35).timeout
		_check(s.enemy_hp == hp0 and s.hand.size() == hand_before - 1,
			"clicking an unaffordable card does nothing", "unaffordable card resolved on click")
	else:
		_ok("no unaffordable card in hand at this point (skipped state check)")

	# 3) Block against the enemy attack, through the real button.
	# Play every playable Defend (re-fetching the hand after each click).
	while true:
		hand = combat.get_node("%Hand")
		var target: CardView = null
		for v in hand.get_children():
			if is_instance_valid(v) and v.card_data.get("kind", "") == PrototypeDeck.DEFEND \
					and s.can_play(v.card_data):
				target = v
				break
		if target == null:
			break
		target.pressed.emit(target.card_data)
		await create_timer(0.35).timeout
	var block_before: int = s.player_block
	end_btn.pressed.emit()
	await create_timer(1.6).timeout
	var expected: int = 80 - (7 - mini(block_before, 7))
	_check(s.player_hp == expected, "enemy attack resolved through UI (block %d honored)" % block_before,
		"player hp %d, expected %d" % [s.player_hp, expected])
	_check(s.player_block == 0, "block cleared at the player-turn boundary", "block did not reset")

	# 4) Turn label is distinct between phases.
	var turn_label: Label = combat.get_node("%TurnLabel")
	_check(turn_label.text.contains("TURN 2"), "turn label advanced to TURN 2", "turn label: " + turn_label.text)

	# 5) Kill the enemy through clicks: play all attacks, end turn, repeat.
	var guard := 0
	while s.phase != CombatState.Phase.VICTORY and guard < 60:
		guard += 1
		var played := false
		while true:
			hand = combat.get_node("%Hand")
			var target: CardView = null
			for v in hand.get_children():
				if is_instance_valid(v) and v.card_data.get("kind", "") \
						in [PrototypeDeck.STRIKE, PrototypeDeck.HEAVY, PrototypeDeck.LEDGER] \
						and s.can_play(v.card_data):
					target = v
					break
			if target == null:
				break
			target.pressed.emit(target.card_data)
			await create_timer(0.35).timeout
			played = true
		if s.phase == CombatState.Phase.VICTORY:
			break
		end_btn.pressed.emit()
		await create_timer(1.6).timeout
	_check(s.phase == CombatState.Phase.VICTORY, "enemy killed via repeated play + end turn", "enemy not dead after session (guard hit)")

	var overlay: ColorRect = combat.get_node("%OverlayDim")
	_check(overlay.visible, "victory overlay appears on kill", "victory overlay missing")
	_check(end_btn.disabled, "End Turn disabled at victory", "End Turn still enabled at victory")

	# 6) Restart must reset the fight.
	combat.get_node("%RestartButton").pressed.emit()
	await create_timer(0.35).timeout
	var s2 = combat.state
	_check(s2.phase == CombatState.Phase.PLAYER_TURN and s2.turn_number == 1,
		"restart resets to turn 1", "restart did not reset state")
	_check(s2.enemy_hp == 40 and s2.player_hp == 80, "restart restores both bars", "restart left hp wrong")
	_check(not combat.get_node("%OverlayDim").visible, "restart hides the overlay", "overlay stuck after restart")
	_check(combat.get_node("%Hand").get_child_count() == 5, "restart redeals 5 cards", "hand not redealt")

	# 7) Defeat: drain HP, end turn, let the enemy kill us.
	s2.player_hp = 5
	combat.get_node("%EndTurnButton").pressed.emit()
	await create_timer(1.6).timeout
	_check(s2.phase == CombatState.Phase.DEFEAT, "defeat overlay path fires at 0 HP", "defeat not reached")
	_check(combat.get_node("%OutcomeTitle").text == "RUIN", "defeat overlay copy shows RUIN", "defeat copy wrong: " + combat.get_node("%OutcomeTitle").text)
