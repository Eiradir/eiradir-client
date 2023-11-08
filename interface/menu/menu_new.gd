extends Control

const MenuOption = preload("res://interface/menu/menu_option.tscn")
var menu_options = ["Option 1", "Option 2", "Option 3"]
var menu_radius = 80

func _ready():
	position = get_parent().get_size() / 2

	for i in range(menu_options.size()):
		var angle = i * 2 * PI / menu_options.size()
		var direction = Vector2(cos(angle), sin(angle))
		_create_menu_option(menu_options[i], direction)

func _create_menu_option(option_name, direction):
	var option_instance = MenuOption.instantiate()
	option_instance.get_node("Button").text = option_name
	option_instance.position = direction * menu_radius
	add_child(option_instance)
