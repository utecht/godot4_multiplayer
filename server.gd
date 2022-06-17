extends Node

@export var PlayerScene = preload("res://Player.tscn")

func _enter_tree():
	if "--server" in OS.get_cmdline_args():
		start_network(true)
	else:
		start_network(false)

	
func start_network(server: bool) -> void:
	var peer = ENetMultiplayerPeer.new()
	if server:
		multiplayer.peer_connected.connect(self.create_player)
		multiplayer.peer_disconnected.connect(self.destroy_player)
		
		peer.create_server(8080)
		print('server listening on 8080')
	else:
		peer.create_client('localhost', 8080)
	
	multiplayer.set_multiplayer_peer(peer)
	
func create_player(id: int) -> void:
	var p = PlayerScene.instantiate()
	p.name = str(id)
	$Players.add_child(p)
	
func destroy_player(id: int) -> void:
	$Players.get_node(str(id)).queue_free()
