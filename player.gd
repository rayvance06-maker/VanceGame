extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D

var is_attacking: bool = false

func _ready() -> void:
	# Fallback: creates the "attack" action mapped to 'E' key if not already in Input Map
	if not InputMap.has_action("attack"):
		InputMap.add_action("attack")
		var event = InputEventKey.new()
		event.keycode = KEY_E
		InputMap.action_add_event("attack", event)

	# Auto-connect the animation_finished signal in code
	if not animated_sprite.animation_finished.is_connected(_on_animated_sprite_2d_animation_finished):
		animated_sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- 1. HANDLE ATTACK INPUT ---
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animated_sprite.play("attack")

	# --- 2. MOVEMENT & JUMPING (Disabled while attacking) ---
	if not is_attacking:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get input direction
		var direction := Input.get_axis("move_left", "move_right")
		
		# Flip sprite direction
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
			
		# Handle running/idle/jumping animations
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
			
		# Apply movement
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# Stop horizontal movement on the ground while attacking
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# --- 3. ANIMATION FINISHED SIGNAL ---
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false

func take_damage(amount: int) -> void:
	print("Enemy hit for ", amount, "damage!")
	queue_free() # Destroys the enemy node
