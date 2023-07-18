extends Node2D
class_name Entity

@export var map_position: Vector2i # TODO needs custom setter that changes position
@export var level: int # TODO needs custom setter that changes position
@export var display_name: String = "" # for name tag
@export var color: Color = Color(1.0, 1.0, 1.0, 1.0) # skin color for characters, item color for items
@export var direction: GridDirections.Keys = GridDirections.Keys.SouthEast
@export var paperdolls: Array[int] = []
@export var paperdoll_colors: Array[Color] = []
@export var visual_traits: Array[int] = []
@export var visual_trait_colors: Array[Color] = []

var animator_script = preload("res://game/entity/animator.gd")
var animator: EntityAnimator
var mobility_script = preload("res://game/entity/mobility.gd")
var mobility: EntityMobility

var id: String
var iso_id: int
var iso: IsoDefinition
var chunk_group: String

func _ready():
	if has_node("AnimatedSprite2D"): 
		animated_sprite = get_node("AnimatedSprite2D")
		animated_sprite.self_modulate = color
		animator = animator_script.new()
		add_child(animator)
	elif has_node("Sprite2D"): 
		sprite = get_node("Sprite2D")
		sprite.self_modulate = color
	update_paperdolls()
	update_visual_traits()
	update_name_tag()
	mobility = mobility_script.new()
	add_child(mobility)

func update_paperdolls():
	for i in range(paperdolls.size()):
		var paperdoll_iso_id = paperdolls[i]
		var paperdoll_iso = Registries.isos.load_entry_by_id(paperdoll_iso_id)
		if !paperdoll_iso || !paperdoll_iso.paperdoll:
			print("invalid paperdoll iso: ", paperdoll_iso_id)
			continue
		var scene = paperdoll_iso.paperdoll.get_scene_for_iso(iso_id)
		if !scene:
			print("no paperdoll scene for iso ", paperdoll_iso_id, " in ", iso_id)
			continue
		var paperdoll = scene.instantiate()
		paperdoll.self_modulate = paperdoll_colors[paperdolls.find(paperdoll_iso_id)]
		add_child(paperdoll)

func update_visual_traits():
	for i in range(visual_traits.size()):
		var visual_trait_id = visual_traits[i]
		var vist = Registries.vists.load_entry_by_id(visual_trait_id)
		if !vist || !vist.paperdoll:
			print("invalid vist: ", visual_trait_id)
			continue
		var scene = vist.paperdoll.get_scene_for_iso(iso_id)
		if !scene:
			print("no paperdoll scene for vist ", visual_trait_id, " in ", iso_id)
			continue
		var paperdoll = scene.instantiate()
		paperdoll.self_modulate = visual_trait_colors[visual_traits.find(visual_trait_id)]
		add_child(paperdoll)















var sprite: Sprite2D
var animated_sprite: AnimatedSprite2D
var name_tag: Label

func update_name_tag():
	if display_name.is_empty():
		if name_tag:
			name_tag.queue_free()
	else:
		name_tag = load("res://interface/game/name_tag.tscn").instantiate()
		name_tag.text = display_name
		var name_tag_parent = get_child(0)
		name_tag_parent.add_child(name_tag)
		name_tag.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, -20)
