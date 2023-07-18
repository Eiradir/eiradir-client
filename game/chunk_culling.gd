extends Node

func _on_camera_map_position_changed(map_pos: Vector2i):
	ChunkManager.clear_out_of_range(map_pos)