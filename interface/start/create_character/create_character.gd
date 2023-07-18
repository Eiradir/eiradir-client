extends Control

signal to_select_character
signal character_created(server: String, id: int)

var _entity_script = preload("res://game/entity.gd")
var _server: String = "https://server.eiradir.net"

var _current: Node
var _customize: Node
var _attributes: Node
var _origin: Node

var _races: Dictionary = {}

var _preview_entity
var _preview_direction = GridDirections.Keys.South
var _selected_hair = {}
var _selected_beard = {}
var _selected_gear = {}
var _selected_gear_color = {}
var _selected_skin_color = Color(1, 1, 1, 1)
var _selected_hair_color = Color(1, 1, 1, 1)
var _selected_beard_color = Color(1, 1, 1, 1)

func init(server: String):
	_server = server

func _ready():
	_customize = preload("res://interface/start/create_character/create_character_customize.tscn").instantiate()
	_customize.skin_color_changed.connect(_on_skin_color_changed)
	_customize.hair_color_changed.connect(_on_hair_color_changed)
	_customize.beard_color_changed.connect(_on_beard_color_changed)
	_customize.hair_changed.connect(_on_hair_changed)
	_customize.beard_changed.connect(_on_beard_changed)
	_customize.gear_changed.connect(_on_gear_changed)
	_customize.gear_color_changed.connect(_on_gear_color_changed)
	_attributes = preload("res://interface/start/create_character/create_character_attributes.tscn").instantiate()
	_attributes.attribute_changed.connect(_on_attribute_changed)
	_origin = preload("res://interface/start/create_character/create_character_origin.tscn").instantiate()
	_origin.origin_changed.connect(_on_origin_changed)

	var result = await Eiradir.server_api.fetch_character_creation_options(_server).completed
	var options = result[0]
	var error = result[1]
	if error:
		print(error) # TODO error handling
		return

	_update_races(options.races)
	_origin.set_trait_options(options.traits)
	_to_customize()
	update_submit_state()

func _update_races(races: Array):
	_races = {}
	%Race.clear()
	for race in races:
		_races[int(race.id)] = race
		%Race.add_item(race.name, race.id)
	_on_race_item_selected(0)

func _to_customize():
	if _current:
		%ContentPane.remove_child(_current)
	_current = _customize
	%ContentPane.add_child(_current)

func _to_attributes():
	if _current:
		%ContentPane.remove_child(_current)
	_current = _attributes
	%ContentPane.add_child(_current)

func _to_origin():
	if _current:
		%ContentPane.remove_child(_current)
	_current = _origin
	%ContentPane.add_child(_current)

func _on_appearance_button_pressed():
	_to_customize()

func _on_attributes_button_pressed():
	_to_attributes()

func _on_origin_button_pressed():
	_to_origin()

func _on_cancel_button_pressed():
	to_select_character.emit()

func update_submit_state():
	var char_name = %CharName.text
	var sex_selected = %Male.is_pressed() || %Female.is_pressed()
	var ready_to_submit = false
	if char_name.is_empty():
		%CreateCharacterButton.set_tooltip_text("You need to specify a name for your character.")
	elif !sex_selected:
		%CreateCharacterButton.set_tooltip_text("You need to choose a sex for your character.")
	elif !_attributes.are_all_points_distributed():
		%CreateCharacterButton.set_tooltip_text("You need to distribute all attribute points.")
	elif !_origin.is_origin_setup():
		%CreateCharacterButton.set_tooltip_text("You need to setup your origin.")
	else:
		%CreateCharacterButton.set_tooltip_text("")
		ready_to_submit = true
	%AttributesButton.text = "Attributes (!)" if !_attributes.are_all_points_distributed() else "Attributes"
	%OriginButton.text = "Origin (!)" if !_origin.is_origin_setup() else "Origin"
	%CreateCharacterButton.set_disabled(!ready_to_submit)


func _on_male_pressed():
	var race = _get_selected_race()
	_customize.update_vist_options(race.visual_trait_options, _get_selected_sex() == "male")
	_update_preview()
	update_submit_state()

func _on_female_pressed():
	var race = _get_selected_race()
	_customize.update_vist_options(race.visual_trait_options, _get_selected_sex() == "male")
	_update_preview()
	update_submit_state()

func _on_char_name_text_changed(_new_text):
	update_submit_state()

func _get_selected_gear():
	var gear = []
	for category in _selected_gear.keys():
		var selected_gear = _selected_gear[category]
		gear.append({id = selected_gear.id, color = _dumb_godot_int_workaround(_selected_gear_color.get(category, Color.WHITE).to_rgba32())})
	return gear

func _get_selected_visual_traits():
	var visual_traits = []
	if _selected_hair.size() > 0:
		visual_traits.append({id = _selected_hair.vist_id, color = _dumb_godot_int_workaround(_selected_hair_color.to_rgba32())})
	if _selected_beard.size() > 0:
		visual_traits.append({id = _selected_beard.vist_id, color = _dumb_godot_int_workaround(_selected_beard_color.to_rgba32())})
	return visual_traits

func _dumb_godot_int_workaround(value: int) -> int:
	var arr = PackedInt32Array()
	arr.append(value)
	return arr[0]

func _on_create_character_button_pressed():
	var character = {
		name = %CharName.text,
		race_id = _get_selected_race().id,
		sex = "Male" if _get_selected_sex() == "male" else "Female",
		age = _origin.get_age(),
		strength = _attributes.get_strength(),
		dexterity = _attributes.get_dexterity(),
		constitution = _attributes.get_constitution(),
		agility = _attributes.get_agility(),
		perception = _attributes.get_perception(),
		intelligence = _attributes.get_intelligence(),
		arcanum = _attributes.get_arcanum(),
		traits = _origin.get_selected_trait_ids(),
		skin_color = _dumb_godot_int_workaround(_selected_skin_color.to_rgba32()),
		gear  = _get_selected_gear(),
		visual_traits = _get_selected_visual_traits(),
	}
	var result = await Eiradir.server_api.create_character(_server, character).completed
	var char_id = result[0]
	var error = result[1]
	if error:
		print(error)
		return
	character_created.emit(_server, char_id)

func _on_race_item_selected(index: int):
	var id: int = %Race.get_item_id(index)
	var race = _races[id]
	_customize.update_skin_colors(race.skin_colors)
	_customize.update_hair_colors(race.hair_colors)
	_customize.update_gear_options(race.gear_options)
	_customize.update_vist_options(race.visual_trait_options, _get_selected_sex() == "male")
	_attributes.update_limits(race.min_stats, race.max_stat_points)
	_update_preview()

func _on_skin_color_changed(color: Color):
	_selected_skin_color = color
	_update_preview()

func _on_hair_color_changed(color: Color):
	_selected_hair_color = color
	_update_preview()

func _on_beard_color_changed(color: Color):
	_selected_beard_color = color
	_update_preview()

func _on_hair_changed(hair: Dictionary):
	_selected_hair = hair
	_update_preview()

func _on_beard_changed(beard: Dictionary):
	_selected_beard = beard
	_update_preview()

func _on_gear_changed(category: String, gear: Dictionary):
	if gear.size() == 0:
		_selected_gear.erase(category)
	else:
		_selected_gear[category] = gear
	_update_preview()

func _on_gear_color_changed(category: String, color: Color):
	_selected_gear_color[category] = color
	_update_preview()

func _get_selected_race():
	var id: int = %Race.get_selected_id()
	return _races[id]

func _get_selected_sex() -> String:
	if %Male.is_pressed():
		return "male"
	if %Female.is_pressed():
		return "female"
	return ""

func _update_preview():
	for child in %Preview.get_children():
		child.queue_free()

	var entity = _entity_script.new()
	var race = _get_selected_race()
	var sex = _get_selected_sex()

	var iso_id = race["%s_iso_id" % sex]	
	var iso = Registries.isos.load_entry_by_id(iso_id)
	var visual = iso.scene.instantiate()
	entity.iso_id = iso_id
	entity.add_child(visual)

	if _selected_hair.size() > 0:
		entity.visual_traits.append(int(_selected_hair.vist_id))
		entity.visual_trait_colors.append(_selected_hair_color)
	if _selected_beard.size() > 0:
		entity.visual_traits.append(int(_selected_beard.vist_id))
		entity.visual_trait_colors.append(_selected_beard_color)

	for category in _selected_gear.keys():
		var gear = _selected_gear[category]
		entity.paperdolls.append(int(gear.iso_id))
		entity.paperdoll_colors.append(_selected_gear_color.get(category, Color.WHITE) if gear.allow_color else Color.WHITE)

	entity.direction = _preview_direction
	entity.scale = Vector2(2, 2)
	entity.color = _selected_skin_color
	%Preview.add_child(entity)

	entity.position = entity.get_viewport_rect().size / 2 + Vector2(0, 100)
	_preview_entity = entity


func _on_direction_value_changed(value: float):
	_preview_direction = GridDirections.horizontal_directions[(int(value)) % GridDirections.horizontal_directions.size()]
	_preview_entity.direction = _preview_direction

func _on_attribute_changed(_attribute: String, _value: int):
	update_submit_state()

func _on_origin_changed():
	update_submit_state()
