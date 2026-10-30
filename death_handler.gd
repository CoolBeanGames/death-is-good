extends Node

@export var spawn_point : Node2D
@export var prefab : PackedScene
@export var wait_time : float = 1
@export var camera : Camera2D
@export var tracked_player : player

func _ready() -> void:
	await  get_tree().process_frame
	spawn()

func on_death():
	tracked_player.died.disconnect(on_death)
	tracked_player = null
	get_tree().create_timer(wait_time).timeout.connect(spawn)

func _process(delta: float) -> void:
	if tracked_player:
		camera.global_position = tracked_player.global_position

func spawn():
	var instance : CharacterBody2D = prefab.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = spawn_point.global_position
	tracked_player = instance
	tracked_player.died.connect(on_death)


func _on_first_death_zone_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
