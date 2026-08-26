extends Area2D

@onready var timer = $Timer

func _on_body_entered(_body: Node2D) -> void:
	print("You Died!")
	timer.start()
	
	
