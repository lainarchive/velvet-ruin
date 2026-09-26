class_name PrototypeDeck
extends RefCounted
## The exact 10-card milestone deck. Cards are plain data; their effects are
## resolved by CombatState. No effect scripting system yet.

const STRIKE := "strike"  # 3x — cost 1, deal 6
const DEFEND := "defend"  # 3x — cost 1, gain 5 block
const HEAVY := "heavy"    # 2x — cost 2, deal 11
const LEDGER := "ledger"  # 1x — cost 1, deal 4 (+4 if a card was discarded this turn)
const INK := "ink"        # 1x — cost 0, draw 1

static func make() -> Array:
	return [
		_card(STRIKE, "Velvet Cut", 1, "Attack", "Deal 6 damage."),
		_card(STRIKE, "Velvet Cut", 1, "Attack", "Deal 6 damage."),
		_card(STRIKE, "Velvet Cut", 1, "Attack", "Deal 6 damage."),
		_card(DEFEND, "Smoke & Veneer", 1, "Skill", "Gain 5 Block."),
		_card(DEFEND, "Smoke & Veneer", 1, "Skill", "Gain 5 Block."),
		_card(DEFEND, "Smoke & Veneer", 1, "Skill", "Gain 5 Block."),
		_card(HEAVY, "Gilt Collapse", 2, "Attack", "Deal 11 damage."),
		_card(HEAVY, "Gilt Collapse", 2, "Attack", "Deal 11 damage."),
		_card(LEDGER, "Bleed the Ledger", 1, "Attack", "Deal 4 damage. Deals 4 more if you discarded a card this turn."),
		_card(INK, "Contract Ink", 0, "Skill", "Draw 1 card."),
	]

static func _card(kind: String, card_name: String, cost: int, type: String, text: String) -> Dictionary:
	return {
		"kind": kind,
		"name": card_name,
		"cost": cost,
		"type": type,
		"text": text,
	}
