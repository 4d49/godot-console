# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends EditorPlugin


const AUTOLOAD_NAME_CONSOLE : String = "Console" # Name of Console singletone.

# Path to console script file.
const SCRIPT_PATH_CONSOLE = "res://addons/godot-console/scripts/console.gd"

const CONSOLE_CONTAINER_NAME = "ConsoleContainer"
const CONSOLE_CONTAINER_SCRIPT = "res://addons/godot-console/scripts/console_container.gd"
const CONSOLE_CONTAINER_ICON = "res://addons/godot-console/icons/console_container.svg"


func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME_CONSOLE, SCRIPT_PATH_CONSOLE)
	add_custom_type(CONSOLE_CONTAINER_NAME, "VBoxContainer", load(CONSOLE_CONTAINER_SCRIPT), load(CONSOLE_CONTAINER_ICON))
	return


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME_CONSOLE)
	remove_custom_type(CONSOLE_CONTAINER_NAME)
	return
