extends VBoxContainer

signal connect

func _ready() -> void:
	$Connect.disabled = true
	ClientState.client_data = ClientData.new()

func _on_Nickname_text_changed(name: String) -> void:
	ClientState.client_data.name = name

	if name.length() >= 3 && $Connect.disabled:
		$Connect.disabled = false
	if name.length() < 3 && !$Connect.disabled:
		$Connect.disabled = true

func _on_Connect_pressed() -> void:
	emit_signal('connect')
