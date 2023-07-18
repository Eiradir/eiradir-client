extends Control

func _ready():
	pass


func _on_spells_property_changed(value: Array):
	print(value)
	%Label.text = str(value)
