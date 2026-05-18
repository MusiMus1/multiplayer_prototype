extends Node3D
@onready var spawn_container: Node3D = $SpawnContainer
@onready var local_container: Node3D = $LocalContainer

func _ready() -> void:
	Global.spawn_container = spawn_container
	Global.local_container = local_container
