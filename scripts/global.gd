extends Node


const BULLET = preload("uid://kl58oa13ur24")
var username : String = ''
var spawn_container : Node3D
var local_container : Node3D




@rpc("any_peer","call_local","reliable")
func spawn_projectile(source, pos, dir , is_dummy = false):
	if (
		(multiplayer.get_unique_id() == multiplayer.get_remote_sender_id() and is_dummy)
		and not multiplayer.is_server()
		) or (
		multiplayer.get_remote_sender_id() == 1 and is_dummy
		):
		#print("RPC Declined")
		return
	
	var projectile_obj : Area3D = BULLET.instantiate()
	var container_to_spawn : Node3D = spawn_container if is_dummy else local_container
	
	#print("Your ID is %d, The player with ID %d sent this RPC." % [multiplayer.get_unique_id(), multiplayer.get_remote_sender_id()])
	#print("Source of the bullet: ",source)
	projectile_obj.source = source
	projectile_obj.direction = dir
	projectile_obj.is_dummy = is_dummy
	projectile_obj.original_position = pos
	container_to_spawn.add_child(projectile_obj, true)
	
	
