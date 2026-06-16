extends Node3D

@export var interact_key := KEY_E
@export var hand_path := NodePath("PlayerModel/CharacterArmature/Skeleton3D/Middle1_L")
@export var held_position := Vector3.ZERO
@export var held_rotation_degrees := Vector3.ZERO
@export var held_scale := Vector3.ONE

@onready var prompt: Label3D = $MeshMaterial/PromptLabel
@onready var prompt_area: Area3D = $MeshMaterial/PromptArea

var nearby_player: Node3D
var picked_up := false

func _ready() -> void:
	prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if picked_up or nearby_player == null:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == interact_key:
		_interact()

func _interact() -> void:
	if multiplayer.multiplayer_peer == null:
		_pick_up_for_player(nearby_player.name)
	elif multiplayer.is_server():
		_pick_up_for_player.rpc(nearby_player.name)
	else:
		_request_pick_up.rpc_id(1, nearby_player.name)

@rpc("any_peer", "reliable")
func _request_pick_up(player_name: StringName) -> void:
	if multiplayer.is_server():
		_pick_up_for_player.rpc(player_name)

@rpc("authority", "call_local", "reliable")
func _pick_up_for_player(player_name: StringName) -> void:
	if picked_up:
		return
	var player := get_tree().current_scene.get_node_or_null(String(player_name)) as Node3D
	if player == null:
		return
	var hand := player.get_node_or_null(hand_path) as Node3D
	if hand == null:
		hand = player
	picked_up = true
	nearby_player = null
	prompt.visible = false
	prompt_area.monitoring = false
	prompt_area.monitorable = false
	reparent(hand, false)
	position = held_position
	rotation_degrees = held_rotation_degrees
	scale = held_scale

func _on_prompt_area_body_entered(body: Node3D) -> void:
	if picked_up or not _is_local_player(body):
		return
	nearby_player = body
	prompt.visible = true

func _on_prompt_area_body_exited(body: Node3D) -> void:
	if body != nearby_player:
		return
	nearby_player = null
	prompt.visible = false

func _is_local_player(body: Node) -> bool:
	if not body is CharacterBody3D:
		return false
	if multiplayer.multiplayer_peer == null:
		return true
	return body.is_multiplayer_authority()
