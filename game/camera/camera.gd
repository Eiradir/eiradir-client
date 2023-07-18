extends Camera2D

signal map_position_changed(pos: Vector2i)

var last_synced_map_position = Vector2i()

func _ready():
	NetworkClient.CameraPositionReceived.connect(_on_camera_position_received)

func _process(_delta):
	var map_pos = _to_map_position()
	if map_pos != last_synced_map_position:
		NetworkClient.SendCameraPosition(Vector3i(map_pos.x, map_pos.y, 0))
		map_position_changed.emit(map_pos)
		last_synced_map_position = map_pos

func _on_camera_position_received(pos: Vector3i):
	position = ChunkManager.map_to_global(Vector2i(pos.x, pos.y))

func _to_map_position() -> Vector2i:
	return ChunkManager.global_to_map(position)