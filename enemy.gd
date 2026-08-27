extends Node2D

const SPEED = 30.0 
var direction = 1
var is_attacking = false

# --- HEALTH SYSTEM ---
@export var max_health: int = 60
var current_health: int

# --- BORDER LIMITS ---
@export var walk_distance: float = 100.0 

var start_x: float
var left_border: float
var right_border: float

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	current_health = max_health
	start_x = position.x
	left_border = start_x - walk_distance
	right_border = start_x + walk_distance

func _process(delta: float) -> void:
	# Stop logic entirely if dead
	if current_health <= 0:
		return

	# --- 1. PLAYER DETECTION & ATTACK LOGIC ---
	var detected_player = null

	# Check active direction raycast for player
	if direction == 1 and ray_cast_right.is_colliding():
		var collider = ray_cast_right.get_collider()
		if collider and collider.is_in_group("player"):
			detected_player = collider

	elif direction == -1 and ray_cast_left.is_colliding():
		var collider = ray_cast_left.get_collider()
		if collider and collider.is_in_group("player"):
			detected_player = collider

	# Handle attack state based on player presence
	if detected_player != null:
		if not is_attacking:
			attack_player(detected_player)
		return # Stop execution here so enemy stays in place while attacking

	# --- 2. PATROL & BORDER CHECK ---
	if position.x >= right_border and direction == 1:
		turn_around(-1)
	elif position.x <= left_border and direction == -1:
		turn_around(1)

	# --- 3. MOVEMENT ---
	position.x += direction * SPEED * delta


func turn_around(new_direction: int) -> void:
	direction = new_direction
	animated_sprite.flip_h = (direction == -1)

func attack_player(player_node) -> void:
	is_attacking = true
	animated_sprite.play("attack")
	
	if player_node.has_method("take_damage"):
		player_node.take_damage(10)

# --- 4. HEALTH & DAMAGE LOGIC ---
func take_damage(amount: int) -> void:
	current_health -= amount
	print("Enemy took damage! Remaining health: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy defeated!")
	# Optional: play a death animation before queue_free
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	queue_free()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
