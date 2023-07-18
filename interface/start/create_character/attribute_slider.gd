@tool
extends Panel

signal value_changed(value: int)

@export var attribute = "none"

var value: int
var _min_value: int
var _max_value: int

func _ready():
	%Label.text = tr("ATTRIBUTE_" + attribute.to_upper())

func _on_spin_box_value_changed(p_value):
	value = p_value
	%Slider.value = p_value
	value_changed.emit(p_value)

func _on_slider_value_changed(p_value):
	value = p_value
	%SpinBox.value = p_value
	value_changed.emit(p_value)

func set_limits(p_min: int, p_max: int):
	_min_value = p_min
	_max_value = p_max
	%SpinBox.min_value = p_min
	%SpinBox.max_value = p_max
	%Slider.min_value = p_min
	%Slider.max_value = p_max


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			value = clamp(value + 1, _min_value, _max_value)
			%SpinBox.value = value
			%Slider.value = value
			value_changed.emit(value)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			value = clamp(value - 1, _min_value, _max_value)
			%SpinBox.value = value
			%Slider.value = value
			value_changed.emit(value)
