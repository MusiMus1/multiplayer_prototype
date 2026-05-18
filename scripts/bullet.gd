extends Area3D

@export var speed : float = 5.0
@export var projectile_range : float = 10.0
@export var original_position : Vector3 = Vector3.FORWARD
@export var direction : Vector3 = Vector3.FORWARD
@export var source : int
@export var is_dummy : bool = false

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready() -> void:
	global_position = original_position
	show()
	
	body_entered.connect(_on_body_entered)
	if not is_dummy:
		set_multiplayer_authority(source)
		multiplayer_synchronizer.queue_free()
	elif source == multiplayer.get_unique_id():
		hide()
		if source != 1:
			set_physics_process(false)
		else:
			collision_shape_3d.disabled = true

func _physics_process(_delta: float) -> void:
	global_position += direction
	if global_position.length() - original_position.length() >= projectile_range:
		if multiplayer.is_server() or not is_dummy:
			queue_free()
		else:
			hide()
			set_physics_process(false)

func _on_body_entered(body : PhysicsBody3D):
	var shooter : CharacterBody3D = Network.get_player_with_id(source)
	if body.name == str(source) or not visible:
		
		return
	
	if is_dummy:
		if multiplayer.is_server():
			queue_free()
		else:
			hide()
			set_physics_process(false)
		print(body.name)
		print("I pretended to hit something")
	else:
		if body.is_in_group("Player"):
			var target_id : int = int(body.name) 
			shooter.register_hit.rpc_id(1, target_id)
		queue_free()
