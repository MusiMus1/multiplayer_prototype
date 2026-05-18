extends Label3D

@export var sibling_camera : Camera3D
var authority_camera : Camera3D

func _ready() -> void:
	await get_tree().process_frame
	authority_camera = Network.get_player_with_id(multiplayer.get_unique_id()).player_camera
	if authority_camera == sibling_camera:
		set_process(false)

func _process(_delta: float) -> void:
	look_at(authority_camera.global_position, Vector3.UP, true)
