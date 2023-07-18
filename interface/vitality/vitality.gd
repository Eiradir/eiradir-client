extends Control

@export var fill_speed: float = 0.1

var target_health: int = 100
var target_health_max: int = 100
var target_hunger: int = 100
var target_hunger_max: int = 100
var target_mana: int = 100
var target_mana_max: int = 100

func _on_health_property_changed(value: int):
	target_health = value

func _on_max_health_property_changed(value: int):
	target_health_max = value

func _on_hunger_property_changed(value: int):
	target_hunger = value

func _on_max_hunger_property_changed(value: int):
	target_hunger_max = value

func _on_mana_property_changed(value: int):
	target_mana = value

func _on_max_mana_property_changed(value: int):
	target_mana_max = value

func _process(delta: float):
	%Health.value = lerp(%Health.value, float(target_health), fill_speed * delta)
	%Health.max_value = lerp(%Health.max_value, float(target_health_max), fill_speed * delta)
	%Hunger.value = lerp(%Hunger.value, float(target_hunger), fill_speed * delta)
	%Hunger.max_value = lerp(%Hunger.max_value, float(target_hunger_max), fill_speed * delta)
	%Mana.value = lerp(%Mana.value, float(target_mana), fill_speed * delta)
	%Mana.max_value = lerp(%Mana.max_value, float(target_mana_max), fill_speed * delta)