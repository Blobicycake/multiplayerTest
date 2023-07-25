extends Node2D

@export var PortBox: Node
@export var IPBox: Node
var LocalPlayer: Node
var peer
var id
# Called when the node enters the scene tree for the first time.
func _ready():
	LocalPlayer = get_node("player")
	pass # Replace with function body.
func _host():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(int(PortBox.text))
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(Callable(self, "get_new_player"))
	id = peer.get_unique_id()
	LocalPlayer.name = str(id)
func _join():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IPBox.text, int(PortBox.text))
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(Callable(self, "get_new_player"))
	id = peer.get_unique_id()
	LocalPlayer.name = str(id)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rpc("send_player")

@rpc("any_peer")
func send_player():
	rpc("recieve_player", id, LocalPlayer.position, LocalPlayer.velocity)
@rpc("any_peer")
func recieve_player(Id: int, position: Vector2, velocity: Vector2):
	var player = get_node(str(Id))
	player.position = position
	player.velocity = velocity
func get_new_player(Id):
	rpc_id(Id, "give_player", id)
	print("getting new players")
@rpc("any_peer")
func give_player(Id):
	rpc_id(Id, "new_player", id)
@rpc("any_peer")
func new_player(Id: int):
	var player: Node = load("res://player.tscn").instantiate()
	player.name = str(Id)
	player.id = Id
	player.ClientId = id
	self.add_child(player)
