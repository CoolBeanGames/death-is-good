class_name player
extends CharacterBody2D

signal died

@export var vel: Vector2
@export var jump_state: int = 0
@export var jump_force = 10
@export var move_speed: float = 5
@export var gravity: float = 9
@export var airborne: bool = false
@export var dead: bool = false
@export var coyote_timer: float = 0
@export var max_coyote_time: float = 0.3


func _process(_delta: float) -> void:
	if not dead and Input.is_action_just_released("die"):
		die()


func _physics_process(delta: float) -> void:
	if not dead:
		_update_coyote_timer(delta)
		_update_horizontal_velocity()
		_handle_jump()
		_update_airborne_state()
		_update_landing_state()

		vel = velocity
		$Sprite_Pivot/Player_Sprite.flip_h = velocity.x < 0
	else:
		velocity.x = 0
		_apply_gravity()

	move_and_slide()
	velocity.x = 0


func die() -> void:
	dead = true
	$AnimationPlayer.play("Die")
	died.emit()
	Data.deaths+=1


func _update_coyote_timer(delta: float) -> void:
	if is_on_floor():
		coyote_timer = max_coyote_time

	coyote_timer -= delta

	if coyote_timer < 0:
		coyote_timer = 0


func _update_horizontal_velocity() -> void:
	var input_axis: float = Input.get_axis("left", "right")
	velocity.x = input_axis * move_speed


func _handle_jump() -> void:
	if (
		Input.is_action_just_released("jump")
		and jump_state != 1
		and coyote_timer > 0
	):
		jump_state = 1
		velocity.y = -jump_force
		coyote_timer = 0


func _apply_gravity() -> void:
	if not is_on_floor():
		velocity.y -= gravity


func _update_airborne_state() -> void:
	_apply_gravity()

	if not is_on_floor():
		airborne = true

		if jump_state != 1:
			jump_state = 2


func _update_landing_state() -> void:
	if airborne and is_on_floor():
		airborne = false
		jump_state = 0
