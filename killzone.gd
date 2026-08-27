extends Area2D

@export var max_health: int = 3
var current_health: int

@onready var timer = $Timer

func _ready() -> void:
	current_health = max_health

# Called when an object enters the enemy's Area2D
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		# 1. Deal damage to the player if they have a take_damage method
		if body.has_method("take_damage"):
			body.take_damage(1)
		
		# 2. Kill/reload sequence
		print("You died!")
		Engine.time_scale = 0.5
		if body.has_node("CollisionShape2D"):
			body.get_node("CollisionShape2D").queue_free()
		timer.start()

# Called when the player hits this enemy
func take_damage(amount: int) -> void:
	current_health -= amount
	print("Enemy HP remaining: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy defeated!")
	queue_free() # Destroys the enemy node

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0 # Reset time scale before reloading
	get_tree().reload_current_scene()
