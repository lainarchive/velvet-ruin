extends SceneTree
## Captures a real rendered 1280x720 screenshot of the combat scene.
## Opens the GL window briefly, saves the frame, and exits.

const OUT_PATH := "res://.tools/screenshot_combat_720.png"

func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/Combat.tscn")
	var combat = scene.instantiate()
	root.add_child(combat)
	for i in 30:
		await process_frame
	var img: Image = root.get_texture().get_image()
	img.save_png(OUT_PATH)
	print("SCREENSHOT_SAVED: ", OUT_PATH, " size=", img.get_size())
	quit(0)
