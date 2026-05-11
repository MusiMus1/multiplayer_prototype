extends Control

@onready var button_join : Button = $Join
@onready var button_quit : Button = $Quit

const MAIN_WORLD : PackedScene = preload("res://assets/scenes/main_world.tscn")


func _ready() -> void:
	if OS.has_feature("server"):
		Network.create_server()
		add_world()
	else:
		button_join.pressed.connect(_on_join)
		button_quit.pressed.connect(func(): get_tree().quit())

func _on_join() -> void:
	Network.join_server()
	add_world()

func add_world() -> void:
	var world_obj = MAIN_WORLD.instantiate()
	get_tree().current_scene.add_child.call_deferred(world_obj)
	hide()
