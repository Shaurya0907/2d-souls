extends Control



func _on_yes_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func _on_no_pressed() -> void:
	get_tree().quit()
