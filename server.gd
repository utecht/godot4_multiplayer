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
		
		var err = peer.create_server(9876)
		if err:
			print(err)
		else:
			print('server listening on 9876')
	else:
		print('attempting to connect...')
		var err = peer.create_client('localhost', 9876)
		if err:
			print(err)
		else:
			print('connected')
	
	multiplayer.set_multiplayer_peer(peer)
#	if server:
#		create_player(multiplayer.get_unique_id())
	
func create_player(id: int) -> void:
	print('creating player')
	var p = PlayerScene.instantiate()
	p.name = str(id)
	$Players.add_child(p)
	
func destroy_player(id: int) -> void:
	print('destroying player')
	$Players.get_node(str(id)).queue_free()
