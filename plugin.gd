# Copyright (c) 2020-2022 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@tool
extends EditorPlugin


const AUTOLOAD_NAME = "Console"
const AUTOLOAD_PATH = "res://addons/godot-console/scripts/console.gd"

const CONSOLE_CONTAINER = "ConsoleContainer"
const CONSOLE_CONTAINER_SCRIPT = "res://addons/godot-console/scripts/console_container.gd"
const CONSOLE_CONTAINER_ICON = "res://addons/godot-console/icons/console_container.svg"


func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	add_custom_type(CONSOLE_CONTAINER, "VBoxContainer", load(CONSOLE_CONTAINER_SCRIPT), load(CONSOLE_CONTAINER_ICON))


func _exit_tree() -> void:
	remove_custom_type(CONSOLE_CONTAINER)
	remove_autoload_singleton(AUTOLOAD_NAME)
