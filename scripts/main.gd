extends Control
## Entry point. Title presentation; transitions into the combat scene.

const COMBAT_SCENE := "res://scenes/Combat.tscn"

@onready var _enter_button: Button = %EnterButton

func _ready() -> void:
	_enter_button.pressed.connect(_on_enter_pressed)

func _on_enter_pressed() -> void:
	get_tree().change_scene_to_file(COMBAT_SCENE)
