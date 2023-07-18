extends Node

var _hud: Control
var keyboard_captured = false
var mouse_occupied = false

func is_mouse_over_hud() -> bool:
	if !_hud:
		_hud = get_node("/root/game/%HUD")
	if !_hud:
		return false
	for child in _hud.get_children():
		if child is Control and _is_mouse_over_control(child):
			return true
	return false

func _is_mouse_over_control(control: Control) -> bool:
	if control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		var rect = control.get_global_rect()
		var mouse_position = control.get_global_mouse_position()
		if rect.has_point(mouse_position):
			return true
	for child in control.get_children():
		if child is Control and _is_mouse_over_control(child):
			return true
	return false

func is_mouse_occupied():
	return mouse_occupied
