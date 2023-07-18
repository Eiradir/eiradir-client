extends VBoxContainer

var tooltip_title = preload("res://interface/tooltip/tooltip_title.tscn")

var nonce: int = 0

func _ready():
	TooltipManager.tooltip_received.connect(_on_tooltip_received)

func _on_tooltip_received(p_nonce: int, items: Array):
	if nonce != p_nonce:
		print("nonce mismatch: %d vs %d" % [nonce, p_nonce])
		return
	for item in items:
		if item.type == 0:
			var child = tooltip_title.instantiate()
			child.text = item.text
			add_child(child)

	var panel = get_parent()
	panel.child_controls_changed()

func _update_tooltip_position(panel):
	var tooltip_pos = get_viewport().get_mouse_position()
	var tooltip_offset = ProjectSettings.get_setting("display/mouse_cursor/tooltip_position_offset")
	var rect = Rect2(tooltip_pos + tooltip_offset, panel.get_contents_minimum_size())
	rect.size = rect.size.clamp(rect.size, panel.get_max_size())
	var viewport_rect = get_viewport().get_visible_rect()
	if rect.size.x + rect.position.x > viewport_rect.size.x + viewport_rect.position.x:
		rect.position.x = tooltip_pos.x - rect.size.x - tooltip_offset.x

		if rect.position.x < viewport_rect.position.x:
			rect.position.x = viewport_rect.position.x + viewport_rect.size.x - rect.size.x
	elif rect.position.x < viewport_rect.position.x:
		rect.position.x = viewport_rect.position.x
	

	if rect.size.y + rect.position.y > viewport_rect.size.y + viewport_rect.position.y:
		rect.position.y = tooltip_pos.y - rect.size.y - tooltip_offset.y

		if rect.position.y < viewport_rect.position.y:
			rect.position.y = viewport_rect.position.y + viewport_rect.size.y - rect.size.y
	elif rect.position.y < viewport_rect.position.y:
		rect.position.y = viewport_rect.position.y

	panel.set_position(rect.position)