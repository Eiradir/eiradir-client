extends Control

@export var center = Vector2i(0, 0)
@export var level = 0
@export var minimap_size = 100

@onready var _content = $Content
@onready var _camera = get_node("/root/game/Camera")

var _minimap_image: Image
var _minimap_texture: ImageTexture

func _ready():
	_camera.map_position_changed.connect(_on_map_position_changed)
	NetworkClient.TileMapReceived.connect(_on_tilemap_received)
	NetworkClient.TileUpdateReceived.connect(_on_tile_update_received)

	_minimap_image = Image.create(minimap_size, minimap_size, false, Image.FORMAT_RGBA8)
	_minimap_texture = ImageTexture.create_from_image(_minimap_image)
	_update_minimap()
	_content.texture = _minimap_texture

func _update_minimap():
	var sx = center.x - minimap_size / 2
	var sy = center.y - minimap_size / 2
	for rx in range(minimap_size):
		for ry in range(minimap_size):
			var map_pos = Vector2i(sx + rx, sy + ry)
			var tilemap = ChunkManager.try_get_tilemap_at(map_pos, level)
			var tile_id = tilemap.get_tile_id(map_pos) if tilemap else 0
			var tile_def = Registries.tiles.load_entry_by_id(tile_id)
			var color = tile_def.color if tile_def else Color(0, 0, 0, 1)
			_minimap_image.set_pixel(rx, ry, color)
	_minimap_texture.update(_minimap_image)

func _on_map_position_changed(map_position: Vector2i):
	center = map_position
	_update_minimap()
	
func _on_tilemap_received(_map_name: String, chunk_pos: Vector3i, _chunk_size: int, tiles):
	_update_minimap()

func _on_tile_update_received(_map_name: String, world_pos: Vector3i, tile_id: int):
	_update_minimap()
