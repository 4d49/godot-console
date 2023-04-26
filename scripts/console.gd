# Copyright (c) 2020-2023 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## ConsoleNode class.
##
## By default used as a Singleton. To create a new console command, use [method create_command].
class_name ConsoleNode
extends Node

## Emitted when the console prints a string.
signal printed_line(string: String)
## Emitted when the console history is cleared.
signal cleared()


var _command_map : Dictionary
var _command_list : PackedStringArray

var _history : PackedStringArray
var _history_index : int


func _init() -> void:
	# Built-in methods:
	create_command("max_fps", Engine.set_max_fps, "The desired frames per second. A value of 0 means no limit.")
	create_command("physics_ticks", Engine.set_physics_ticks_per_second, "Set physic tick per second.")
	# Custom methods:
	create_command("clear", clear, "Clear the console history.")
	create_command("help", _command_help, "Show all console command.")
	create_command("version", _command_version, "Show engine version.")
	create_command("test", _command_test, "Test console output.")
	create_command("quit", _command_quit, "Quit the application.")

## Return [param true] if the console has a command.
func has_command(command: String) -> bool:
	return _command_map.has(command)

## Return [param true] if command name is valid.
func is_valid_name(command: String) -> bool:
	return command.is_valid_identifier()

## Add a command to the console.
## Can be used to directly add a custom command.
func add_command(command: ConsoleCommand) -> void:
	assert(is_instance_valid(command) and command.is_valid(), "Invalid command.")
	assert(not has_command(command.get_name()), "Has command.")

	if is_instance_valid(command) and command.is_valid() and not has_command(command.get_name()):
		_command_map[command.get_name()] = command
		_command_list.clear() # Clear for lazy initialization.

## Remove a command from the console.
func remove_command(command: String) -> bool:
	if _command_map.erase(command):
		_command_list.clear()
		return true

	return false

## Return command.
func get_command(command: String) -> ConsoleCommand:
	return _command_map[command]

## Create and add a new console command.
func create_command(command: String, callable: Callable, description := "") -> void:
	assert(not has_command(command), "Has command.")
	assert(is_valid_name(command), "Invalid command name.")
	assert(callable.is_valid(), "Invalid callable.")

	if not has_command(command) and is_valid_name(command) and callable.is_valid():
		self.add_command(ConsoleCommand.new(command, callable, description))

## Print string to the console.
func print_line(string: String) -> void:
	printed_line.emit(string + "\n")

## Execute command. First word must be a command name, other is arguments.
@warning_ignore("return_value_discarded")
func execute(string: String) -> void:
	var args : PackedStringArray = string.split(" ", false)
	if args.is_empty():
		return

	_history.push_back(string)
	_history_index = _history.size()

	print_line("[color=GRAY]> " + string + "[/color]")

	if not has_command(args[0]):
		print_line("[color=RED]Command \"" + string + "\" not found.[/color]")
		return

	var command := get_command(args[0])

	assert(is_instance_valid(command), "Invalid ConsoleCommand.")
	if not is_instance_valid(command):
		return

	args.remove_at(0) # Remove name from arguments.

	var result : String = command.execute(args)
	if result:
		print_line(result)

## Return the previously entered command.
func get_prev_command() -> String:
	_history_index = wrapi(_history_index - 1, 0, _history.size())
	return "" if _history.is_empty() else _history[_history_index]

## Return the next entered command.
func get_next_command() -> String:
	_history_index = wrapi(_history_index + 1, 0, _history.size())
	return "" if _history.is_empty() else _history[_history_index]

## Return a list of all commands.
func get_command_list() -> PackedStringArray:
	if _command_list.is_empty(): # Lazy initialization.
		_command_list = _command_map.keys()
		_command_list.sort()

	return _command_list

## Return autocomplete command.
func autocomplete_command(string: String) -> String:
	if string.is_empty():
		return string

	for command in get_command_list():
		if command.begins_with(string):
			return command

	return string

## Return a list of autocomplete commands.
@warning_ignore("return_value_discarded")
func autocomplete_list(string: String) -> PackedStringArray:
	var list := PackedStringArray()
	if string.is_empty():
		return list

	for command in get_command_list():
		if command.begins_with(string):
			list.push_back(command)

	return list

## Clear the console history.
func clear() -> void:
	_history.clear()
	_history_index = 0

	cleared.emit()


func _command_help() -> void:
	for i in get_command_list():
		print_line(i + "- " + get_command(i).get_description())


func _command_version() -> String:
	return "Godot Engine {major}.{minor}.{patch}".format(Engine.get_version_info())


func _command_test() -> String:
	return "The quick brown fox jumps over the lazy dog."


func _command_quit() -> void:
	get_tree().quit()
