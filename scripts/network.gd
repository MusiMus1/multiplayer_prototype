
extends Node

const PORT = 9999
const IP_ADDRESS = "127.0.0.1"
const TUBE_CONTEXT = preload("uid://dyhyjccibqkiu")

@onready var tube_client : TubeClient = TubeClient.new()

var session_id : String = ''
var tube_enabled : bool = true

var player_scene : PackedScene = preload("res://objects/proto_player.tscn")

func _ready() -> void:
	if tube_enabled:
		tube_client.context = TUBE_CONTEXT
		get_tree().root.add_child.call_deferred(tube_client)

func create_tube_server() -> void:
	signal_connection()
	tube_client.create_session()
	session_id = tube_client.session_id
	add_player(1)

func join_tube_server(id : String) -> void:
	tube_client.join_session(id)
	session_id = tube_client.session_id
	signal_connection()
	multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_connected_to_server() -> void:
	add_player(multiplayer.get_unique_id())

func add_player(peer_id : int) -> void:
	#if id == 1:
		#return
	var player_obj : CharacterBody3D = player_scene.instantiate()
	player_obj.name = str(peer_id)
	get_tree().current_scene.add_child(player_obj, true)
	player_obj.global_position = Vector3(randi_range(-2,2), 1,randi_range(-2,2))

func remove_player(peer_id : int) -> void:
	if peer_id == 1:
		leave_server()
	
	var player_list = get_player_list()
	
	var player_to_remove := player_list.find_custom(func(item): return item.name == str(peer_id))
	
	if player_to_remove != -1:
		player_list[player_to_remove].queue_free()

func get_player_list() -> Array:
	return get_tree().get_nodes_in_group("Player")

func get_player_with_id(player_id : int) -> CharacterBody3D:
	var player : CharacterBody3D = null
	var player_idx : int = get_player_list().find_custom(func(item):
		return item.name == str(player_id)
		)
	
	if player_idx == -1 or get_player_list()[player_idx] == null:
		print("Player not found")
		return
	player = get_player_list()[player_idx]
	return player
	
func leave_server() -> void:
	cleanse_connection()
	tube_client.leave_session()
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	
	get_tree().reload_current_scene()
	print(tube_client)
func signal_connection() -> void:
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

func cleanse_connection() -> void:
	multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	multiplayer.peer_connected.disconnect(add_player)


# Enet Multiplayer Peer. But we're not using Enet anymore.
#var enet_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

# Enet Multiplayer functions.
#func create_server() -> void:
	#print("Oi")
	#enet_peer.create_server(PORT)
	#multiplayer.multiplayer_peer = enet_peer
	#multiplayer.peer_connected.connect(_add_player)
	#
#func join_server()-> void:
	#enet_peer.create_client(IP_ADDRESS,PORT)
	#multiplayer.peer_connected.connect(_add_player)
	#multiplayer.multiplayer_peer = enet_peer
	#multiplayer.connected_to_server.connect(_on_connected_to_server)
