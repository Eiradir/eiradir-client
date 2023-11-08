extends Node

const direction_update_throttle = 500
const move_timeout = 1000

var target_id: String
var target_ref: WeakRef
var move_requested_at: int
var last_direction_update: int
var last_synced_direction: GridDirections.Keys

func _ready():
	NetworkClient.ControlChanged.connect(_control_changed)
	NetworkClient.EntityMoved.connect(_on_entity_moved)

func _process(_delta):
	var direction = Vector2.ZERO
	if !FocusManager.keyboard_captured:
		if Input.is_action_pressed("move_up"):
			direction.y += 1
		if Input.is_action_pressed("move_down"):
			direction.y -= 1
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_right"):
			direction.x += 1
	var target = target_ref.get_ref() if target_ref else null
	if !target && !target_id.is_empty():
		target = _set_control_target(target_id)
	if target:
		var now = Time.get_ticks_msec()
		if direction != Vector2.ZERO:
			var grid_direction = GridDirections.from_input(direction)
			if Input.is_action_pressed("use"):
				target.direction = grid_direction
			else:
				var ready_to_move = !target.mobility || (!target.mobility.moving || target.mobility.move_progress > 0.9)
				if (move_requested_at == 0 || now - move_requested_at > move_timeout) && ready_to_move:
					var target_pos = GridDirections.apply_offset(target.map_position, grid_direction)
					NetworkClient.SendMoveInput(target_pos)
					move_requested_at = now
		if target.direction != last_synced_direction && now - last_direction_update > direction_update_throttle:
			NetworkClient.SendTurnInput(target.direction)
			last_direction_update = now
			last_synced_direction = target.direction

func _control_changed(entity_id: String, _control_type: int, _seat: int):
	_set_control_target(entity_id)

func _set_control_target(entity_id: String):
	target_id = entity_id
	var entity = %EntityManager.get_node_or_null(entity_id)
	target_ref = weakref(entity)
	return entity
	
func _on_entity_moved(entity_id: String, _world_pos: Vector3i):
	if entity_id == target_id:
		move_requested_at = 0
