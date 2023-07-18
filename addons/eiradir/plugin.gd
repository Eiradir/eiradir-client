@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("Eiradir", "res://addons/eiradir/Eiradir/eiradir.gd")

func _exit_tree():
	remove_autoload_singleton("Eiradir")
