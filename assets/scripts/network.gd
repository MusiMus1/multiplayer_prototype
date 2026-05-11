
extends Node

const PORT = 9999
const IP_ADDRESS = "127.0.0.1"

var enet_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var player_scene : PackedScene = preload("res://assets/objects/proto_player.tscn")

func create_server() -> void:
	print("Oi")
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(_add_player)
	
func join_server()-> void:
	enet_peer.create_client(IP_ADDRESS,PORT)
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_connected_to_server() -> void:
	_add_player(multiplayer.get_unique_id())

func _add_player(id : int) -> void:
	if id == 1:
		return
	var player_obj = player_scene.instantiate()
	player_obj.name = str(id)
	get_tree().current_scene.add_child(player_obj)
	
