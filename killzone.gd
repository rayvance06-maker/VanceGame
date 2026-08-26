extends Area2D

@onready var timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	# Make sure only the Player triggers death
	if body.is_in_group("player") or body.name == "Player":
		print("You died!")

		body.queue_free()
		
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0 # Reset time scale if frozen
	get_tree().reload_current_scene()
