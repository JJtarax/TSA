extends CharacterBody2D

@export var movement_data : PlayerMovementData

var air_jump = false
var just_wall_jumped = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	handle_wall_jump()
	var input_axis = Input.get_axis("left", "right")
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	update_animation(input_axis)
	apply_movement()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func handle_wall_jump():
	if not is_on_wall(): return
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("up"):
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true
#	if Input.is_action_just_pressed("right") and wall_normal == Vector2.RIGHT:
#		velocity.x = wall_normal.x * movement_data.speed
#		velocity.y = movement_data.jump_velocity
#		just_wall_jumped = true

func handle_jump():
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_pressed("up"):
			velocity.y = movement_data.jump_velocity
			coyote_jump_timer.stop()
	elif not is_on_floor():
		if Input.is_action_just_released("up") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
		
		if Input.is_action_just_pressed("up") and air_jump:
			velocity.y = movement_data.jump_velocity * 0.8
			air_jump = false

func handle_acceleration(input_axis, delta):
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x - move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)


func apply_friction(input_axis, delta):
	if input_axis ==0:
		velocity.x = move_toward(velocity.x,0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor:
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistence * delta)

func update_animation(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	if not is_on_floor():
		animated_sprite_2d.play("jump")
		
func apply_movement():
	if Input.is_action_just_pressed("Trigger"):
		movement_data = load("res://FastMovementData.tres")
	if Input.is_action_just_pressed("aim"):
		movement_data = load("res://SlowMovementData.tres")
	if Input.is_action_just_released("Trigger") or Input.is_action_just_released("aim"):
		movement_data = load("res://DefualtMovementData.tres")

