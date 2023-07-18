extends Resource
class_name PaperdollDefinition

@export var mappings: Array[PaperdollMapping] = []

var cache: Dictionary = {} 

func get_scene_for_iso(iso_id: int) -> PackedScene:
    var existing = cache.get(iso_id, null)
    if existing != null:
        return existing
    for mapping in mappings:
        var mapping_iso_id = Registries.isos.get_entry_id(mapping.iso)
        if mapping_iso_id == iso_id:
            cache[iso_id] = mapping.scene
            return mapping.scene
    return null