extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sync_velocity : Vector3
var aim_sensitivity : float = 0.005

@onready var body_mesh : MeshInstance3D = $MeshInstance3D
@onready var camera_anchor : Node3D = $MeshInstance3D/CameraAnchor
@onready var player_camera : Camera3D = $MeshInstance3D/CameraAnchor/Camera3D

func _ready() -> void:
	set_multiplayer_authority(int(name))
	print(name)
	if not is_multiplayer_authority():
		return
	
	player_camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority() and event is InputEventMouseMotion:
		body_mesh.rotate_y(event.relative.x * aim_sensitivity)
		camera_anchor.rotate_x(-event.relative.y * aim_sensitivity)
		camera_anchor.rotation.x = clamp(camera_anchor.rotation.x, deg_to_rad(-90), deg_to_rad(28))

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		velocity = sync_velocity
		return
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
