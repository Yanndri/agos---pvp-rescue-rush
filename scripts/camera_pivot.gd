extends Node3D

@export var player: Node3D
@export var camera: Camera3D

@export var follow_speed := 12.0

@export var vehicle_zoom_multiplier := 1.8
@export var zoom_speed := 6.0

@export var rotate_left_action := "pan_left"
@export var rotate_right_action := "pan_right"
@export var rotate_step_degrees := 45.0
@export var rotate_speed := 10.0

var target_yaw := 0.0
var normal_camera_position := Vector3.ZERO


func _ready() -> void:
	target_yaw = rotation.y

	if camera != null:
		# Saves your current isometric camera position from the editor.
		normal_camera_position = camera.position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return

	if event.is_action_pressed(rotate_left_action):
		target_yaw += deg_to_rad(rotate_step_degrees)
	elif event.is_action_pressed(rotate_right_action):
		target_yaw -= deg_to_rad(rotate_step_degrees)


func _process(delta: float) -> void:
	if player == null or camera == null:
		return

	_follow_player(delta)
	_rotate_camera(delta)
	_update_zoom(delta)


func _follow_player(delta: float) -> void:
	global_position = global_position.lerp(
		player.global_position,
		min(follow_speed * delta, 1.0)
	)


func _rotate_camera(delta: float) -> void:
	rotation.y = lerp_angle(
		rotation.y,
		target_yaw,
		min(rotate_speed * delta, 1.0)
	)


func _update_zoom(delta: float) -> void:
	var target_camera_position := normal_camera_position

	if player.get("is_driving_vehicle") == true:
		target_camera_position = normal_camera_position * vehicle_zoom_multiplier

	camera.position = camera.position.lerp(
		target_camera_position,
		min(zoom_speed * delta, 1.0)
	)
