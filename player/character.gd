extends CharacterBody2D

@export var vel : Vector2
@export var jump_state : int = 0
@export var jump_force = 10
@export var move_speed : float = 5
@export var gravity : float = 9
@export var airborne : bool = false

func _physics_process(delta: float) -> void:
	var input_axis : float = Input.get_axis("left","right")
	velocity.x = input_axis * move_speed
	
	print("can jump: " + str(Input.is_action_just_released("jump") and jump_state == 0 and is_on_floor()))
	
	if Input.is_action_just_released("jump") and jump_state == 0 and is_on_floor():
		jump_state += 1
		velocity.y = -jump_force
	
	if !is_on_floor():
		velocity.y -= gravity
		airborne = true
		if jump_state != 1:
			jump_state = 2
	
	if airborne and is_on_floor():
		airborne=false
		jump_state = 0
	
	move_and_slide()
	vel = velocity
	
	$Sprite_Pivot/Player_Sprite.flip_h = velocity.x < 0
	
	velocity.x = 0
