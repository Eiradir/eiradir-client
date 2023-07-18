extends Control

var system_color = Color.html("#00A4CC")
var chat_color = Color.html("#B1B1B1")
var whisper_color = Color.html("#7F8C8D")
var shout_color = Color.html("#F13C20")
var emote_color = Color.html("#B377D6")
var command_color = Color.html("#2ECC71")

var chat_line_scene = preload("res://interface/chat/chat_line.tscn")
var command_history: Array[String] = []
var command_history_cursor = -1
var command_history_prior = ""

var just_submitted = false

func _ready():
	add_chat_message("Welcome to Eiradir", system_color)
	NetworkClient.CommandResponseReceived.connect(_command_response_received)

func add_chat_message(message: String, color: Color) -> void:
	var chat_line = chat_line_scene.instantiate()
	chat_line.text = message
	chat_line.modulate = color
	%ChatContent.add_child(chat_line)
	await %ScrollPane.get_v_scroll_bar().changed
	scroll_to_bottom()

func scroll_to_bottom():
	%ScrollPane.set_v_scroll(%ScrollPane.get_v_scroll_bar().get_max())

func submit_chat(message: String) -> void:
	if message.begins_with("/"):
		submit_command(message)
		return
	$Messages/SubmitChatMessage.send(message)

func submit_command(message: String) -> void:
	NetworkClient.SendCommand(message.substr(1), Vector3i.ZERO, "")
	command_history.append(message)
	command_history_cursor = -1

func _command_response_received(response: String) -> void:
	add_chat_message(response, command_color)

func _on_chat_input_gui_input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.keycode == KEY_UP:
		if command_history_cursor == -1:
			command_history_prior = %ChatInput.text
		command_history_cursor = min(command_history_cursor + 1, command_history.size() - 1)
		_restore_command_history()
		accept_event()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_DOWN:
		command_history_cursor = max(command_history_cursor - 1, -1)
		_restore_command_history()
		accept_event()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		submit_chat(%ChatInput.text)
		%ChatInput.clear()
		%ChatInput.release_focus()
		just_submitted = true
		accept_event()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		%ChatInput.release_focus()
		accept_event()

func _process(_delta: float):
	if Input.is_action_just_pressed("chat") and not just_submitted:
		%ChatInput.grab_focus()
		%ChatInput.set_caret_column(%ChatInput.text.length())
	just_submitted = false

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		var rect: Rect2 = %ChatInput.get_global_rect()
		if !rect.has_point(event.position):
			%ChatInput.release_focus()

func _restore_command_history():
	if command_history_cursor >= 0:
		%ChatInput.text = command_history[command_history.size() - command_history_cursor - 1]
	else:
		%ChatInput.text = command_history_prior
	%ChatInput.set_caret_column(%ChatInput.text.length())
		
func _on_chat_input_focus_entered():
	FocusManager.keyboard_captured = true

func _on_chat_input_focus_exited():
	FocusManager.keyboard_captured = false

func _on_chat_message_message_received(message: String, type: int, _entity_id: String):
	if type == 0:
		add_chat_message(message, chat_color)
	elif type == 1:
		add_chat_message(message, emote_color)
	elif type == 2:
		add_chat_message(message, shout_color)
	elif type == 3:
		add_chat_message(message, whisper_color)
