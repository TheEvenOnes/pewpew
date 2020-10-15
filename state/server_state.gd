extends Node

enum State {
	Init = 0,
	Lobby = 1,
	Preparing = 2,
	Arena = 3,
	Ending = 4
}

var connected_clients: Dictionary = {}
var server_name: String
var server_state = State.Init

func on_client_connected(client_data: ClientData) -> void:
	connected_clients[client_data.id] = client_data
	printt('client connected', client_data)

func on_client_disconnected(client_id: String) ->void:
	connected_clients.erase(client_id)
	printt('client disconnected', client_id)

func get_connected_clients() -> Dictionary:
	return connected_clients

func refuse_new_connections() -> void:
	get_tree().get_network_peer().set_refuse_new_network_connections(true)

func allow_new_connections() -> void:
	get_tree().get_network_peer().set_refuse_new_network_connections(false)
