extends Control

@onready var line_edit_username: LineEdit = $Panel/VBoxContainer/LineEditUsername
@onready var line_edit_session_id: LineEdit = $Panel/VBoxContainer/LineEditSessionID
@onready var button_create: Button = $Panel/VBoxContainer/ButtonCreate
@onready var button_join: Button = $Panel/VBoxContainer/ButtonJoin
@onready var button_quit: Button = $Panel/VBoxContainer/ButtonQuit

const MAIN_WORLD : PackedScene = preload("res://scenes/main_world.tscn")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	button_create.pressed.connect(_pressed_create_server)
	button_join.pressed.connect(_pressed_join_server)
	button_quit.pressed.connect(func(): get_tree().quit())
	
	line_edit_username.text_changed.connect(_username_changed)
	line_edit_session_id.text_changed.connect(_session_id_changed)
	
	# Enet code.
	#if OS.has_feature("server"):
		#Network.create_server()
		#add_world()
	#else:
		#button_join.pressed.connect(_on_join)
		#button_quit.pressed.connect(func(): get_tree().quit())
	
func _pressed_create_server() -> void:
	Network.create_tube_server()
	add_world()

func _pressed_join_server() -> void:
	Network.join_tube_server(line_edit_session_id.text)
	add_world()

func _session_id_changed(new_text : String) -> void:
	button_join.disabled = new_text == '' or line_edit_username.text == ''

func _username_changed(new_text : String) -> void:
	button_create.disabled = new_text == ''
	button_join.disabled = new_text == '' or line_edit_session_id.text == ''
	Global.username = new_text

func add_world() -> void:
	var world_obj = MAIN_WORLD.instantiate()
	get_tree().current_scene.add_child.call_deferred(world_obj)
	hide()
