extends Control

signal skin_color_changed(color: Color)
signal hair_color_changed(color: Color)
signal beard_color_changed(color: Color)
signal hair_changed(hair: Dictionary)
signal beard_changed(beard: Dictionary)
signal gear_changed(category: String, iso_id: int)
signal gear_color_changed(category: String, color: Color)

var none_item_texture = preload("res://assets/items/misc/locked_slot.png")

var _gear_options: Dictionary = {}
var _skin_colors: Array[Color] = []
var _hair_colors: Array[Color] = []
var _hairs: Array[Dictionary] = []
var _beards: Array[Dictionary] = []

func update_skin_colors(skin_colors: Array):
	_skin_colors.clear()
	%SkinColor.clear()
	for hex in skin_colors:
		var color = Color.html(hex)
		%SkinColor.add_icon_item(_create_color_texture(color))
		_skin_colors.append(color)
	%SkinColor.select(0)
	_on_skin_color_item_selected(0)

func update_hair_colors(hair_colors: Array):
	_hair_colors.clear()
	for hex in hair_colors:
		var color = Color.html(hex)
		_hair_colors.append(color)
	%HairColor.set_presets(_hair_colors)
	%BeardColor.set_presets(_hair_colors)

func update_vist_options(vist_options: Dictionary, include_beards: bool):
	_hairs.clear()
	%Hair.clear()
	%Hair.add_icon_item(none_item_texture)
	_hairs.append({})
	for hair in vist_options.get("hairs", []):
		%Hair.add_item(hair.name)
		_hairs.append(hair)

	_beards.clear()
	%Beard.clear()
	if include_beards:
		%Beard.add_icon_item(none_item_texture)
		_beards.append({})
		for beard in vist_options.get("beards", []):
			%Beard.add_item(beard.name)
			_beards.append(beard)
	%BeardLabel.visible = _beards.size() > 1
	%Beard.visible = _beards.size() > 1
	%BeardColor.visible = _beards.size() > 1

func update_gear_options(gear_options: Dictionary):
	_gear_options = gear_options
	%Hats.clear()
	%Hats.add_icon_item(none_item_texture)
	for item in gear_options.get("hats", []):
		var iso = Registries.isos.load_entry_by_id(item.iso_id)
		if iso:
			%Hats.add_icon_item(iso.texture)
		else:
			%Hats.add_item(item.name)
	%Shirts.clear()
	%Shirts.add_icon_item(none_item_texture)
	for item in gear_options.get("shirts", []):
		var iso = Registries.isos.load_entry_by_id(item.iso_id)
		if iso:
			%Shirts.add_icon_item(iso.texture)
		else:
			%Shirts.add_item(item.name)
	%Robes.clear()
	%Robes.add_icon_item(none_item_texture)
	for item in gear_options.get("robes", []):
		var iso = Registries.isos.load_entry_by_id(item.iso_id)
		if iso:
			%Robes.add_icon_item(iso.texture)
		else:
			%Robes.add_item(item.name)
	%Pants.clear()
	%Pants.add_icon_item(none_item_texture)
	for item in gear_options.get("pants", []):
		var iso = Registries.isos.load_entry_by_id(item.iso_id)
		if iso:
			%Pants.add_icon_item(iso.texture)
		else:
			%Pants.add_item(item.name)
	%Shoes.clear()
	%Shoes.add_icon_item(none_item_texture)
	for item in gear_options.get("shoes", []):
		var iso = Registries.isos.load_entry_by_id(item.iso_id)
		if iso:
			%Shoes.add_icon_item(iso.texture)
		else:
			%Shoes.add_item(item.name)

func _on_skin_color_item_selected(index: int):
	skin_color_changed.emit(_skin_colors[index])

func _on_hair_item_selected(index: int):
	hair_changed.emit(_hairs[index])
	%HairColor.visible = index > 0

func _on_beard_item_selected(index: int):
	beard_changed.emit(_beards[index])
	%BeardColor.visible = index > 0

func _create_color_texture(color: Color) -> Texture2D:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var icon = ImageTexture.new()
	icon.set_image(image)
	return icon

func _on_shirts_item_selected(index: int):
	if index == 0:
		gear_changed.emit("shirts", {})
		return
	var gear = _gear_options["shirts"][index - 1]
	gear_changed.emit("shirts", gear)
	%ShirtColor.visible = gear.allow_color

func _on_shirt_color_color_changed(color: Color):
	gear_color_changed.emit("shirts", color)

func _on_pants_item_selected(index: int):
	if index == 0:
		gear_changed.emit("pants", {})
		return
	var gear = _gear_options["pants"][index - 1]
	gear_changed.emit("pants", gear)
	%PantsColor.visible = gear.allow_color

func _on_pants_color_color_changed(color: Color):
	gear_color_changed.emit("pants", color)

func _on_shoes_item_selected(index: int):
	if index == 0:
		gear_changed.emit("shoes", {})
		return
	var gear = _gear_options["shoes"][index - 1]
	gear_changed.emit("shoes", gear)
	%ShoesColor.visible = gear.allow_color

func _on_shoes_color_color_changed(color: Color):
	gear_color_changed.emit("shoes", color)

func _on_hats_item_selected(index: int):
	if index == 0:
		gear_changed.emit("hats", {})
		return
	var gear = _gear_options["hats"][index - 1]
	gear_changed.emit("hats", gear)
	%HatColor.visible = gear.allow_color

func _on_hat_color_color_changed(color: Color):
	gear_color_changed.emit("hats", color)

func _on_robes_item_selected(index: int):
	if index == 0:
		gear_changed.emit("robes", {})
		return
	var gear = _gear_options["robes"][index - 1]
	gear_changed.emit("robes", gear)
	%RobeColor.visible = gear.allow_color

func _on_robe_color_color_changed(color: Color):
	gear_color_changed.emit("robes", color)

func _on_hair_color_color_changed(color: Color):
	hair_color_changed.emit(color)

func _on_beard_color_color_changed(color: Color):
	beard_color_changed.emit(color)
	
