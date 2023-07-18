extends Node

@export var enabled: bool = true
@export var pan_speed = 1000
@export var zoom_speed = 0.05

var target: Camera2D

func _ready():
	target = get_parent()

func _input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("pan_camera"):
		var delta = event.relative
		target.position -= delta / target.zoom.x
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		var new_zoom = clamp(target.zoom.x + zoom_speed, 0.01, 10 if Input.is_action_pressed("use") else 1)
		target.zoom.x = new_zoom
		target.zoom.y = new_zoom
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		var new_zoom = clamp(target.zoom.x - zoom_speed, 0.01, 10 if Input.is_action_pressed("use") else 1)
		target.zoom.x = new_zoom
		target.zoom.y = new_zoom

func _process(delta):
	var movement = Vector2()
	if !FocusManager.keyboard_captured:
		if Input.is_action_pressed("move_up"):
			movement.y -= 1
		if Input.is_action_pressed("move_left"):
			movement.x -= 1
		if Input.is_action_pressed("move_down"):
			movement.y += 1
		if Input.is_action_pressed("move_right"):
			movement.x += 1

	if movement.length() > 0:
		var speed = pan_speed / target.zoom.x
		if Input.is_action_pressed("use"):
			speed *= 2
		movement = movement.normalized() * speed * delta
		target.position += movement