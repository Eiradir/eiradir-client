extends Node
class_name EntityMobility

var entity: Entity
var moving = false
var move_start_pos = Vector2()
var move_end_pos = Vector2()
var move_time_passed = 0.0
var move_time = 0.5
var move_progress = 0.0

const TILE_SIZE = Vector2(76, 37)

func _ready():
	entity = get_parent()

func _process(delta):
	if moving:
		move_time_passed += delta
		move_progress = move_time_passed / move_time
		entity.position = move_start_pos.lerp(move_end_pos, move_progress)

		if move_progress >= 1.0:
			moving = false
			move_progress = 0.0
			move_time_passed = 0.0
			if entity.animator:
				entity.animator.moving = false

func move_grid(p_direction: GridDirections.Keys):
	if moving:
		return
	moving = true
	entity.direction = p_direction
	move_start_pos = entity.position
	var iso_offset = GridDirections.get_iso_offset(p_direction)
	var tile_offset = iso_offset * TILE_SIZE
	move_end_pos = entity.position + tile_offset
	if entity.animator:
		entity.animator.moving = true

func move_to(world_position: Vector3i):
	var end_position = ChunkManager.map_to_global(Vector2i(world_position.x, world_position.y))
	moving = true
	move_start_pos = entity.position
	move_end_pos = end_position
	if entity.animator:
		entity.animator.moving = true
