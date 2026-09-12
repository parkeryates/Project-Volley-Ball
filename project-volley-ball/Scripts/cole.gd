extends CharacterBody2D

@export var speed: float = 300.0
@export var dive_speed: float = 800.0 
@export var dive_friction: float = 6.0  

# 1. NEW: Squishes vertical speed to match the overhead 3/4 camera perspective
# 0.6 means vertical movement travels at 60% of horizontal pixel speed
@export var vertical_scale: float = 0.75  

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_diving: bool = false

func _ready() -> void:
	sprite.animation_finished.connect(_on_dive_finished)

func _physics_process(delta: float) -> void:
	# 1. DIVE STATE PHYSICS
	if is_diving:
		var decay_rate = 1.0 - exp(-dive_friction * delta)
		velocity = velocity.lerp(Vector2.ZERO, decay_rate)
		
		move_and_slide()
		return

	# 2. NORMAL STATE PHYSICS
	var input_direction := Input.get_vector("Left", "Right", "Up", "Down")
	
	# Apply the vertical scale to the input vector BEFORE calculating velocity
	input_direction.y *= vertical_scale
	
	velocity = input_direction * speed
	move_and_slide()

	# Handle Flipping Face Direction
	if input_direction.x != 0:
		sprite.flip_h = (input_direction.x < 0)

	# Handle Input & Animation States
	if Input.is_action_just_pressed("Dive"):
		start_dive()
	elif input_direction == Vector2.ZERO:
		sprite.play("Idle")
	else:
		sprite.play("Run")

func start_dive() -> void:
	is_diving = true
	sprite.play("Dive")
	
	var dive_direction = Input.get_vector("Left","Right","Up","Down")
	
	if dive_direction == Vector2.ZERO:
		var facing = -1.0 if sprite.flip_h else 1.0
		dive_direction = Vector2(facing, 0)
	else:
		dive_direction = dive_direction.normalized()
		
		# Apply the exact same visual perspective squish to your dive direction!
		dive_direction.y *= vertical_scale
		
	velocity = dive_direction * dive_speed

func _on_dive_finished() -> void:
	if sprite.animation == "Dive":
		is_diving = false
