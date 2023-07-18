extends AnimatedSprite2D

const DIRECTIONS = {
	"north": Vector2(0, -38),
	"northeast": Vector2(38, -19),
	"east": Vector2(76, 0),
	"southeast": Vector2(38, 19),
	"south": Vector2(0, 38),
	"southwest": Vector2(-38, 19),
	"west": Vector2(-76, 0),
	"northwest": Vector2(-38, -19)
}
const TILE_SIZE = Vector2(76, 37)
const MOVE_TIME = 1.0

var current_direction = "north"
var moving = false
var move_start_pos = Vector2()
var move_end_pos = Vector2()
var move_progress = 0.0
var move_timer = 0.0
var wait_timer = 0.0

func _ready():
	play("standing_" + current_direction)
	set_process(true)

func _process(delta):
	if moving:
		move_progress += delta / MOVE_TIME
		position = move_start_pos.lerp(move_end_pos, move_progress)

		if move_progress >= 1.0:
			moving = false
			move_progress = 0.0
			play("standing_" + current_direction)
			wait_timer = randf_range(1.0, 4.0)
	else:
		wait_timer -= delta
		if wait_timer <= 0.0:
			choose_direction()

func choose_direction():
	moving = true
	current_direction = DIRECTIONS.keys()[randi() % DIRECTIONS.size()]
	move_start_pos = position
	move_end_pos = position + DIRECTIONS[current_direction]
	play("walking_" + current_direction)
