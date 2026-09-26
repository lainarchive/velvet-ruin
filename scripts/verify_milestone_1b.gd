extends SceneTree
## Headless verification for Milestone 1B: state-level combat rules plus
## scene/UI integration. Uses a seeded CombatState for deterministic draws.

const PASS := "VERIFY-OK: "
const FAIL := "VERIFY-FAIL: "

var _failures := 0

func _ok(msg: String) -> void:
	print(PASS + msg)

func _fail(msg: String) -> void:
	_failures += 1
	print(FAIL + msg)

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	if cond:
		_ok(ok_msg)
	else:
		_fail(fail_msg)

func _new_state() -> CombatState:
	return CombatState.new(20260925)

func _initialize() -> void:
	_check_deck_and_start()
	_check_energy_and_play()
	_check_defense()
	_check_ledger_bonus()
	_check_reshuffle()
	await _check_scene_integration()
	if _failures == 0:
		print("VERIFY: ALL CHECKS PASSED")
	else:
		print("VERIFY: %d CHECK(S) FAILED" % _failures)
	quit(1 if _failures > 0 else 0)

func _check_deck_and_start() -> void:
	var s := _new_state()
	_check(s.hand.size() == 5, "combat starts with 5 cards in hand", "hand != 5: %d" % s.hand.size())
	_check(s.energy == 3, "energy starts at 3", "energy != 3: %d" % s.energy)
	_check(s.draw_pile.size() == 5 and s.discard_pile.size() == 0,
		"deck split 5 draw / 5 hand", "pile split wrong: draw=%d discard=%d" % [s.draw_pile.size(), s.discard_pile.size()])
	var total := s.draw_pile.size() + s.hand.size() + s.discard_pile.size()
	_check(total == 10, "deck totals 10 cards", "deck total != 10: %d" % total)

func _find_card(s: CombatState, kind: String) -> Dictionary:
	for card in s.hand:
		if card.get("kind", "") == kind:
			return card
	return {}

func _check_energy_and_play() -> void:
	var s := _new_state()
	var strike := _find_card(s, PrototypeDeck.STRIKE)
	_check(not strike.is_empty(), "strike available in opening hand", "no strike in opening hand")

	var before_enemy := s.enemy_hp
	_check(s.play_card(strike), "playing 1-cost card succeeds", "play_card(strike) failed")
	_check(s.energy == 2, "energy 3 -> 2 after 1-cost card", "energy != 2 after play: %d" % s.energy)
	_check(s.enemy_hp == before_enemy - 6, "strike deals 6 to enemy", "strike damage wrong")
	_check(s.discard_pile.size() == 1 and s.hand.size() == 4, "card moved hand -> discard",
		"hand/discard wrong after play")

	# Spend everything, then prove a 2-cost card is unplayable at 1 energy.
	var spent := true
	while s.energy > 1:
		var any := {}
		for card in s.hand:
			if int(card.get("cost", 0)) <= s.energy - 1:
				any = card
				break
		if any.is_empty():
			spent = false
			break
		s.play_card(any)
	_check(spent, "energy spendable down to 1", "could not spend energy down")
	if not s.hand.is_empty():
		var heavy := _find_card(s, PrototypeDeck.HEAVY)
		if heavy.is_empty():
			var probe: Dictionary = s.hand[0]
			_check(not s.can_play(probe) or int(probe.get("cost", 0)) <= s.energy,
				"unaffordable card rejected", "can_play true for unaffordable card")
		else:
			_check(not s.can_play(heavy), "2-cost card unplayable at 1 energy", "can_play(heavy) true at 1 energy")
			var hp0 := s.enemy_hp
			_check(not s.play_card(heavy), "play_card rejects unaffordable card", "play_card(heavy) succeeded")
			_check(s.enemy_hp == hp0, "rejected play deals no damage", "enemy hp changed on rejected play")

func _check_defense() -> void:
	var s := _new_state()
	var defend := _find_card(s, PrototypeDeck.DEFEND)
	_check(not defend.is_empty(), "defend available in opening hand", "no defend in opening hand")
	if defend.is_empty():
		return
	s.play_card(defend)
	_check(s.player_block == 5, "defend grants 5 block", "block != 5 after defend: %d" % s.player_block)
	s.end_player_turn()
	s.begin_enemy_action()
	_check(s.player_hp == 80 - 2 and s.player_block == 0, "block absorbs 5 of 7, then resets",
		"block math wrong: hp=%d block=%d" % [s.player_hp, s.player_block])

func _check_ledger_bonus() -> void:
	var s := _new_state()
	var hp0 := s.enemy_hp
	s.cards_discarded_this_turn = 0
	s.resolve_effect({"kind": PrototypeDeck.LEDGER})
	_check(s.enemy_hp == hp0 - 4, "ledger deals 4 with no prior discard", "ledger base damage wrong")
	s.cards_discarded_this_turn = 1
	s.resolve_effect({"kind": PrototypeDeck.LEDGER})
	_check(s.enemy_hp == hp0 - 12, "ledger deals 8 after a discard this turn", "ledger bonus wrong")
	var h := s.hand.size()
	s.resolve_effect({"kind": PrototypeDeck.INK})
	_check(s.hand.size() == h + 1, "ink draws 1 card", "ink did not draw")
	# Discard counter must reset when a new player turn begins.
	s.end_player_turn()
	s.begin_enemy_action()
	s.begin_player_turn()
	_check(s.cards_discarded_this_turn == 0, "discard counter resets on new turn", "discard counter not reset")

func _check_reshuffle() -> void:
	var s := _new_state()
	# Turn 1 ends: 5 cards to discard. Turn 2 draws the remaining 5 from draw.
	s.end_player_turn()
	s.begin_enemy_action()
	s.begin_player_turn()
	_check(s.discard_pile.size() == 5, "turn 2 draws out the draw pile",
		"discard != 5: %d" % s.discard_pile.size())
	_check(s.draw_pile.size() == 0, "draw pile empty after turn 2 draw", "draw pile should be empty")
	# Turn 2 ends: all 10 sit in discard. Turn 3 draw triggers the reshuffle.
	s.end_player_turn()
	s.begin_enemy_action()
	s.begin_player_turn()
	_check(s.hand.size() == 5, "reshuffle refills hand to 5", "hand != 5 after reshuffle: %d" % s.hand.size())
	_check(s.draw_pile.size() == 5, "reshuffle restores draw pile to 5", "draw != 5 after reshuffle")
	_check(s.discard_pile.size() == 0, "reshuffle drains discard into draw", "discard not drained after reshuffle")
	_check(s.energy == 3, "new turn restores energy", "energy not restored")

func _check_victory_defeat() -> void:
	var s := _new_state()
	s.enemy_hp = 5
	var strike := _find_card(s, PrototypeDeck.STRIKE)
	_check(not strike.is_empty() and s.play_card(strike), "killing blow plays", "could not play killing blow")
	_check(s.phase == CombatState.Phase.VICTORY, "enemy at 0 HP -> VICTORY", "victory phase not reached")
	_check(s.is_over(), "state reports combat over after victory", "is_over false after victory")

	var d := _new_state()
	d.player_hp = 5
	d.end_player_turn()
	d.begin_enemy_action()
	_check(d.phase == CombatState.Phase.DEFEAT, "player at 0 HP -> DEFEAT", "defeat phase not reached")
	_check(d.is_over(), "state reports combat over after defeat", "is_over false after defeat")

func _check_scene_integration() -> void:
	_check_victory_defeat()
	var scene: PackedScene = load("res://scenes/Combat.tscn")
	_check(scene != null, "Combat.tscn loads", "Combat.tscn failed to load")
	if scene == null:
		return
	var combat = scene.instantiate()
	_check(combat != null, "Combat.tscn instantiates", "Combat.tscn failed to instantiate")
	if combat == null:
		return
	root.add_child(combat)
	await process_frame
	await process_frame

	var s = combat.state
	var hand: HBoxContainer = combat.get_node("%Hand")
	_check(hand.get_child_count() == 5, "UI shows 5 card views", "hand views != 5: %d" % hand.get_child_count())

	# Play a card through the UI click path. Capture before the view is freed.
	var view: CardView = hand.get_child(0)
	var cost: int = int(view.card_data.get("cost", 0))
	var played_kind: String = str(view.card_data.get("kind", ""))
	var energy0: int = s.energy
	view.pressed.emit(view.card_data)
	await create_timer(0.35).timeout
	_check(s.energy == energy0 - cost,
		"UI click spends energy (%d -> %d)" % [energy0, s.energy],
		"energy wrong after UI play: %d" % s.energy)
	_check(hand.get_child_count() == s.hand.size(), "hand view rebuilt after play", "hand views out of sync")

	# End turn through the UI and let the enemy sequence play out.
	combat.get_node("%EndTurnButton").pressed.emit()
	await create_timer(1.6).timeout
	var turn_label: Label = combat.get_node("%TurnLabel")
	_check(turn_label.text.contains("TURN 2"), "turn label advances to TURN 2", "turn label stuck: " + turn_label.text)
	_check(s.energy == 3, "energy restored on new turn", "energy not restored after UI end turn")
	_check(s.hand.size() == 5, "new hand drawn on new turn", "hand not redrawn: %d" % s.hand.size())
	# If the clicked card was a Defend, its Block must absorb 5 of the 7 damage.
	var expected_hp: int = 78 if played_kind == PrototypeDeck.DEFEND else 73
	_check(s.player_hp == expected_hp, "enemy attack resolved through UI (block applied if played)",
		"player hp wrong: %d (expected %d)" % [s.player_hp, expected_hp])

	# Outcome overlays.
	s.phase = CombatState.Phase.VICTORY
	combat._refresh_all()
	var overlay: ColorRect = combat.get_node("%OverlayDim")
	_check(overlay.visible and combat.get_node("%OutcomeTitle").text == "THE CONTRACT CLOSES",
		"victory overlay shows", "victory overlay missing")
	s.phase = CombatState.Phase.DEFEAT
	combat._refresh_all()
	_check(overlay.visible and combat.get_node("%OutcomeTitle").text == "RUIN",
		"defeat overlay shows", "defeat overlay missing")
	var end_btn: Button = combat.get_node("%EndTurnButton")
	_check(end_btn.disabled, "End Turn disabled when combat over", "End Turn enabled after combat over")

	combat.queue_free()
