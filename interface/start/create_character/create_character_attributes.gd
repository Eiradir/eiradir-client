extends Control

signal attribute_changed(attribute: String, value: int)

var _max_stat: int = 20
var _max_stat_points: int = 85

func _ready():
	_update_description("strength")

func update_limits(min_stats: Dictionary, max_stat_points: int):
	%Strength.set_limits(min_stats["strength"], _max_stat)
	%Dexterity.set_limits(min_stats["dexterity"], _max_stat)
	%Constitution.set_limits(min_stats["constitution"], _max_stat)
	%Agility.set_limits(min_stats["agility"], _max_stat)
	%Perception.set_limits(min_stats["perception"], _max_stat)
	%Intelligence.set_limits(min_stats["intelligence"], _max_stat)
	%Arcanum.set_limits(min_stats["arcanum"], _max_stat)
	_max_stat_points = max_stat_points
	_update_points_left()

func _get_distributed_points() -> int:
	var sum = %Strength.value + %Dexterity.value + %Constitution.value + %Agility.value + %Perception.value + %Intelligence.value + %Arcanum.value
	return sum

func _update_points_left():
	var points_left = _max_stat_points - _get_distributed_points()
	if points_left < 0:
		%PointsLeft.modulate = Color.RED
		%PointsLeft.text = tr("TOO_MANY_ATTRIBUTE_POINTS_DISTRIBUTED").format({points_left = points_left})
	elif points_left > 0:
		%PointsLeft.modulate = Color.YELLOW
		%PointsLeft.text = tr("ATTRIBUTE_POINTS_LEFT_TO_DISTRIBUTE").format({points_left = points_left})
	else: 
		%PointsLeft.modulate = Color.GREEN
		%PointsLeft.text = tr("ALL_ATTRIBUTE_POINTS_DISTRIBUTED").format({points_left = points_left})

func _on_arcanum_value_changed(_value: int):
	_update_points_left()
	attribute_changed.emit("arcanum", _value)

func _on_intelligence_value_changed(_value: int):
	_update_points_left()
	attribute_changed.emit("intelligence", _value)

func _on_perception_value_changed(_value: int):
	_update_points_left()
	attribute_changed.emit("perception", _value)

func _on_agility_value_changed(_value: int):
	_update_points_left()
	attribute_changed.emit("agility", _value)

func _on_constitution_value_changed(_value: int):
	_update_points_left()
	attribute_changed.emit("constitution", _value)

func _on_dexterity_value_changed(_value: int):
	_update_points_left()
	attribute_changed.emit("dexterity", _value)

func _on_strength_value_changed(_value: int):
	_update_points_left()
	attribute_changed.emit("strength", _value)

func _on_strength_mouse_entered():
	_update_description("strength")

func _on_dexterity_mouse_entered():
	_update_description("dexterity")

func _on_arcanum_mouse_entered():
	_update_description("arcanum")

func _on_intelligence_mouse_entered():
	_update_description("intelligence")

func _on_perception_mouse_entered():
	_update_description("perception")

func _on_agility_mouse_entered():
	_update_description("agility")

func _on_constitution_mouse_entered():
	_update_description("constitution")

func _update_description(attribute: String):
	%AttributeTitle.text = tr("ATTRIBUTE_%s" % attribute.to_upper())
	%AttributeDescription.text = tr("ATTRIBUTE_%s_DESCRIPTION" % attribute.to_upper())

func are_all_points_distributed() -> bool:
	return _get_distributed_points() == _max_stat_points

func get_strength() -> int:
	return %Strength.value

func get_dexterity() -> int:
	return %Dexterity.value

func get_arcanum() -> int:
	return %Arcanum.value

func get_intelligence() -> int:
	return %Intelligence.value

func get_perception() -> int:
	return %Perception.value

func get_agility() -> int:
	return %Agility.value

func get_constitution() -> int:
	return %Constitution.value