extends Node

var port: int
var max_clients: int
var server_address: String

# Player info, associate ID to data
var connected_clients_data = {}

func _ready() -> void:
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	port = int(arguments['port']) if arguments.has('port') else 50000
	max_clients = int(arguments['max-clients']) if arguments.has('max-clients') else 8
	server_address = arguments['server-address'] if arguments.has('server-address') else "127.0.0.1"

	if "--server" in OS.get_cmdline_args():
		printt('running as server')
		printt('port', port)
		printt('max clients', max_clients)

		var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
		peer.create_server(port, max_clients)
		get_tree().network_peer = peer

	else:
		printt('running as client')
		printt('address', server_address)
		printt('port', port)

	# invoked both on server and clients
	get_tree().connect("network_peer_connected", self, "_on_client_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_client_disconnected")

func _on_Login_connect() -> void:
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	peer.create_client(server_address, port)
	get_tree().network_peer = peer

	# invoked only on clients
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	get_tree().connect("connection_failed", self, "_on_connection_failed")


# invoked both on server and on clients
func _on_client_connected(id: int) -> void:
	# Called on both clients and server when a peer connects. Send my info to it.
	if get_tree().is_network_server():
		printt('send connected_to_server over to connected client', id)
		rpc_id(id, "connected_to_server", server_address)
	else:
		printt('respond to server with own info', id, ClientState.client_data, ClientState.client_data.name)
		rpc_id(id, "register_connected_client", inst2dict(ClientState.client_data))

# invoked both on server and on clients
func _on_client_disconnected(id: int) -> void:
	printt('client disconnected', id)
	connected_clients_data.erase(id) # Erase player from info.s


# invoked only on clients
func _on_connected_to_server():
	pass # Only called on clients, not server. Will go unused; not useful here.

# invoked only on clients
func _on_server_disconnected() -> void:
	pass # Server kicked us; show error and abort.

# invoked only on clients
func _on_connection_failed() -> void:
	pass # Could not even connect to server; abort.

remote func connected_to_server(info) -> void:
	printt('from client', info)

remote func register_connected_client(client_data: Dictionary):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the client_data
	connected_clients_data[id] = dict2inst(client_data)
	printt('from server', connected_clients_data)
