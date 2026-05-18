extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var sync_velocity : Vector3
@export var username : String = ''
var aim_sensitivity : float = 0.005
var game_paused : bool = false

var peer_id : int = 1:
	set(value):
		peer_id = value
		set_multiplayer_authority(peer_id)

@onready var body_mesh : MeshInstance3D = $MeshInstance3D
@onready var camera_anchor : Node3D = $MeshInstance3D/CameraAnchor
@onready var player_camera : Camera3D = $MeshInstance3D/CameraAnchor/Camera3D
@onready var pause_menu: Control = $PauseMenu
@onready var label_session_id: Label = $PauseMenu/Panel/VBoxContainer/CopyContainer/HBoxContainer/LabelSessionID
@onready var label_username: Label3D = $MeshInstance3D/LabelUsername
@onready var button_leave: Button = $PauseMenu/Panel/ButtonLeave
@onready var button_copy_id: Button = $PauseMenu/Panel/VBoxContainer/CopyContainer/HBoxContainer/ButtonCopyID
@onready var ball_mole: MeshInstance3D = $BallMole
@onready var ray_cast_aim: RayCast3D = $MeshInstance3D/CameraAnchor/Camera3D/RayCastAim
@onready var marker_3d: Marker3D = $MeshInstance3D/Nose/Marker3D

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready() -> void:
	peer_id = int(name)
	
	set_multiplayer_authority(peer_id)
	multiplayer_synchronizer.set_multiplayer_authority(peer_id)
	
	label_session_id.text = Network.session_id
	#print(peer_id)
	if not is_multiplayer_authority():
		set_process(false)
		#set_physics_process(false)
		return
	button_copy_id.pressed.connect(func(): DisplayServer.clipboard_set(label_session_id.text))
	button_leave.pressed.connect(Network.leave_server)
	label_username.text = Global.username
	label_username.hide()
	player_camera.make_current()
	ball_mole.show()
	username = label_username.text
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority() and event is InputEventMouseMotion and not game_paused:
		body_mesh.rotate_y(-event.relative.x * aim_sensitivity)
		camera_anchor.rotate_x(-event.relative.y * aim_sensitivity)
		camera_anchor.rotation.x = clamp(camera_anchor.rotation.x, deg_to_rad(-90), deg_to_rad(28))

func _process(_delta: float) -> void:
	ball_mole.global_position = ray_cast_aim.get_collision_point()
	
	if Input.is_action_just_pressed("pause"):
		toggle_pause_menu()
	
	if Input.is_action_just_pressed("shoot") and not game_paused:
		shoot()
	

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		velocity = sync_velocity
		return
	
	sync_velocity = velocity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("left", "right", "forward", "backwards")
	var direction := (body_mesh.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	sync_velocity = velocity
	move_and_slide()

func shoot() -> void:
	var shoot_direction : Vector3 = marker_3d.global_position.direction_to(ray_cast_aim.to_global(ray_cast_aim.target_position))
	if ray_cast_aim.is_colliding():
		shoot_direction = marker_3d.global_position.direction_to(ray_cast_aim.get_collision_point())
	
	if multiplayer.is_server():
		Global.spawn_projectile(peer_id, marker_3d.global_position, shoot_direction, false)
		Global.spawn_projectile(peer_id, marker_3d.global_position, shoot_direction, true)
		return
	Global.spawn_projectile(peer_id, marker_3d.global_position, shoot_direction, false)
	Global.spawn_projectile.rpc_id(1,peer_id,marker_3d.global_position, shoot_direction, true)

func toggle_pause_menu() -> void:
	pause_menu.visible = !pause_menu.visible
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if pause_menu.visible else Input.MOUSE_MODE_CAPTURED
	game_paused = pause_menu.visible

@rpc("any_peer", "call_local", "reliable")
func register_hit(target_id : int):
	var target_player : CharacterBody3D = Network.get_player_with_id(target_id)
	
	if target_player.has_method("take_damage"):
		target_player.take_damage(20.0, username)
	
	print("You hit "+target_player.username)

func take_damage(damage : float, shooter_name : String):
	print("You took ",damage, " damage by ", shooter_name)
