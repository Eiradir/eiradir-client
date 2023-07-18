extends Control

signal color_changed(color: Color)

var custom_color_texture: ImageTexture = null

var _colors = [
	Color(0.878, 0.482, 0.482),  # Red
	Color(0.482, 0.678, 0.878),  # Blue
	Color(0.482, 0.878, 0.529),  # Green
	Color(0.882, 0.878, 0.482),  # Yellow
	Color(0.878, 0.482, 0.878),  # Purple
	Color(0.878, 0.686, 0.482),  # Orange
	Color(0.682, 0.682, 0.682),  # Gray
	Color(0.878, 0.878, 0.878),  # White
	Color(0.086, 0.086, 0.086),  # Black
	Color(0.482, 0.737, 0.878),  # Light Blue
]

func set_presets(colors: Array):
	_colors = colors
	%Color.clear()
	for color in _colors:
		%Color.add_icon_item(_create_color_texture(color))
	custom_color_texture = _create_color_texture(Color(1.0, 1.0, 1.0))
	%Color.add_icon_item(custom_color_texture)

func _ready():
	set_presets(_colors)

func _create_color_texture(color: Color) -> ImageTexture:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var icon = ImageTexture.new()
	icon.set_image(image)
	return icon

func _on_color_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int):
	if index == %Color.get_item_count() - 1 && mouse_button_index == 1:
		%ColorPickerPopup.position = get_viewport_rect().size / 2
		%ColorPickerPopup.show()

func _on_color_item_selected(index):
	if index < _colors.size():
		color_changed.emit(_colors[index])
	else:
		color_changed.emit(%ColorPicker.color)

func _on_color_picker_color_changed(color: Color):
	var image = custom_color_texture.get_image()
	image.fill(color)
	custom_color_texture.set_image(image)
	color_changed.emit(color)
