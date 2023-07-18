extends Sprite2D

func _ready():
	fade_in()

func fade_in():
	self.modulate = Color(1, 1, 1, 0)  # make sure sprite is initially invisible
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_callback(self.queue_free)
