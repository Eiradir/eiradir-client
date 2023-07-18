extends Resource
class_name TileDefinition

@export var source_id: int = 0
@export var variants: Array[Vector2i] = []
@export var refuses_transitions: bool = false
@export var cannot_transition: bool = false
@export var color: Color = Color(1, 1, 1, 1)

func init(p_variants: Array[Vector2i] = []):
    variants = p_variants