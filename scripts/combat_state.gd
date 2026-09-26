class_name CombatState
extends RefCounted
## Single source of truth for combat. UI only reads this and calls these methods.
## Prototype-sized: one enemy, deterministic when seeded, no frameworks.

signal turn_changed
signal state_changed

const MAX_ENERGY := 3
const MAX_HP := 80
const ENEMY_MAX_HP := 40
const ENEMY_ATTACK := 7
const HAND_DRAW := 5

enum Phase { PLAYER_TURN, ENEMY_TURN, VICTORY, DEFEAT }

var rng := RandomNumberGenerator.new()
var phase: int = Phase.PLAYER_TURN
var turn_number: int = 1

var player_hp: int = MAX_HP
var player_max_hp: int = MAX_HP
var player_block: int = 0

var energy: int = MAX_ENERGY
var max_energy: int = MAX_ENERGY

var enemy_hp: int = ENEMY_MAX_HP
var enemy_max_hp: int = ENEMY_MAX_HP
var enemy_name: String = "THE UNDERSIGNED"
var enemy_intent: int = ENEMY_ATTACK

var draw_pile: Array = []
var hand: Array = []
var discard_pile: Array = []

var cards_discarded_this_turn: int = 0

func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		rng.seed = seed_value
	_start()

func _start() -> void:
	draw_pile = PrototypeDeck.make()
	_shuffle()
	_draw_cards(HAND_DRAW)
	energy = MAX_ENERGY
	enemy_intent = ENEMY_ATTACK

func _shuffle() -> void:
	# Fisher-Yates using the state RNG so verification can seed it.
	for i in range(draw_pile.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = draw_pile[i]
		draw_pile[i] = draw_pile[j]
		draw_pile[j] = tmp

func _draw_cards(n: int) -> void:
	for i in n:
		_draw_one()

func _draw_one() -> void:
	if draw_pile.is_empty():
		if discard_pile.is_empty():
			return
		draw_pile = discard_pile.duplicate()
		_shuffle()
		discard_pile.clear()
	if not draw_pile.is_empty():
		hand.append(draw_pile.pop_back())

func is_player_turn() -> bool:
	return phase == Phase.PLAYER_TURN

func is_over() -> bool:
	return phase == Phase.VICTORY or phase == Phase.DEFEAT

func can_play(card: Dictionary) -> bool:
	return is_player_turn() and energy >= int(card.get("cost", 0))

func play_card(card: Dictionary) -> bool:
	if not can_play(card):
		return false
	var hand_index := hand.find(card)
	if hand_index == -1:
		return false
	energy -= int(card.get("cost", 0))
	hand.remove_at(hand_index)
	resolve_effect(card)
	discard_pile.append(card)
	state_changed.emit()
	return true

func resolve_effect(card: Dictionary) -> void:
	match card.get("kind", ""):
		PrototypeDeck.STRIKE:
			enemy_hp = max(0, enemy_hp - 6)
		PrototypeDeck.HEAVY:
			enemy_hp = max(0, enemy_hp - 11)
		PrototypeDeck.DEFEND:
			player_block += 5
		PrototypeDeck.LEDGER:
			var dmg := 4
			if cards_discarded_this_turn > 0:
				dmg += 4
			enemy_hp = max(0, enemy_hp - dmg)
		PrototypeDeck.INK:
			_draw_one()
	if enemy_hp <= 0:
		phase = Phase.VICTORY

func _apply_damage_to_player(amount: int) -> int:
	var remaining := amount
	if player_block > 0:
		var absorbed: int = mini(player_block, remaining)
		player_block -= absorbed
		remaining -= absorbed
	player_hp = max(0, player_hp - remaining)
	return amount - remaining

func end_player_turn() -> void:
	if not is_player_turn() or is_over():
		return
	phase = Phase.ENEMY_TURN
	discard_hand()
	state_changed.emit()

func discard_hand() -> void:
	while not hand.is_empty():
		var card = hand.pop_back()
		discard_pile.append(card)
		cards_discarded_this_turn += 1

func begin_enemy_action() -> Dictionary:
	# Deterministic single enemy: attack for 7, then show next intent.
	if phase != Phase.ENEMY_TURN:
		return {"through": 0, "absorbed": 0, "defeat": false}
	var block_before := player_block
	var through := _apply_damage_to_player(ENEMY_ATTACK)
	var absorbed := block_before - player_block
	enemy_intent = ENEMY_ATTACK
	if player_hp <= 0:
		phase = Phase.DEFEAT
	return {"through": through, "absorbed": absorbed, "defeat": phase == Phase.DEFEAT}

func begin_player_turn() -> void:
	if is_over():
		return
	phase = Phase.PLAYER_TURN
	turn_number += 1
	energy = max_energy
	player_block = 0
	cards_discarded_this_turn = 0
	_draw_cards(HAND_DRAW)
	state_changed.emit()
	turn_changed.emit()
