extends Node

var registry = preload("res://registry/registry.gd")
var tiles = registry.new()
var transitions = registry.new()
var isos = registry.new()
var vists = registry.new()
var paperdolls = registry.new()
var hud_types = registry.new()

func _ready():
	tiles.load_registry("res://data/tiles")
	add_child(tiles)
	transitions.load_registry("res://data/transitions")
	add_child(transitions)
	isos.load_registry("res://data/isos")
	add_child(isos)
	vists.load_registry("res://data/vists")
	add_child(vists)
	paperdolls.load_registry("res://data/paperdolls")
	add_child(paperdolls)
	hud_types.load_registry("res://data/huds")
	add_child(hud_types)
