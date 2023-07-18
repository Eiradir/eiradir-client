extends Node
class_name EntityAnimator

var entity: Entity
var sprite: AnimatedSprite2D
var idle_animation = "idle"
var active_animation = idle_animation
var supports_motion: bool = false
var supports_directions: bool = false

var last_direction: GridDirections.Keys
var moving = false
var moving_time = 1.0

func _ready():
	entity = get_parent()
	sprite = entity.get_node("AnimatedSprite2D")
	supports_motion = sprite.sprite_frames.has_animation("walking_north")
	supports_directions = sprite.sprite_frames.has_animation("idle_north")
	idle_animation = "idle" if supports_directions or sprite.sprite_frames.has_animation("idle") else "default"
	last_direction = GridDirections.Keys.None
	set_animation(idle_animation)

func _process(_delta):
	if entity.direction != last_direction:
		set_animation(active_animation, sprite.get_playing_speed(), sprite.frame, sprite.frame_progress)
		last_direction = entity.direction

	if !moving and active_animation != idle_animation:
		set_animation(idle_animation)
	elif moving and active_animation != "walking":
		set_animation("walking", 2.0)

func set_animation(p_anim: String, p_speed: float = 1.0, frame: int = 0, frame_progress: float = 0.0) -> void:
	active_animation = p_anim
	if supports_directions:
		play_on_all(p_anim + "_" + GridDirections.get_direction_name(entity.direction), p_speed, frame, frame_progress)
	else:
		play_on_all(p_anim, p_speed, frame, frame_progress)

func play_on_all(p_anim: String, p_speed: float = 1.0, frame: int = 0, frame_progress: float = 0.0):
	for child in entity.get_children():
		var child_animated_sprite = child if child is AnimatedSprite2D else null
		if child_animated_sprite:
			child_animated_sprite.play(p_anim, p_speed)
			child_animated_sprite.frame = frame
			child_animated_sprite.frame_progress = frame_progress
