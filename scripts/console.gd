# Copyright (c) 2020-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## ConsoleNode class.
##
## By default used as a Singleton. To create a new console command, use [method create_command].
extends Node

## Emitted when the console prints a string.
signal printed_line(string: String)
## Emitted when the console history is cleared.
signal cleared()


var _commands: Dictionary[String, Dictionary] = {}
var _command_list: PackedStringArray = PackedStringArray()

var _history : PackedStringArray
var _history_index : int


func _init() -> void:
	create_command("clear", clear, "Clear the console history.")
	create_command("help", _command_help, "Show all console command.")

## Return [param true] if the console has a command.
func has_command(command: String) -> bool:
	return _commands.has(command)

## Return [param true] if command name is valid.
func is_valid_name(command: String) -> bool:
	return command.is_valid_ascii_identifier()

## Remove a command from the console.
func remove_command(command: String) -> void:
	if _commands.erase(command):
		_command_list.clear()

## Return command description.
func get_command_description(command: String) -> String:
	return _commands[command][&"description"] if _commands.has(command) else ""

## Create and add a new console command.
func create_command(command_name: String, callable: Callable, description: String = "") -> void:
	assert(not has_command(command_name), "Command '%s' already exists." % command_name)
	assert(is_valid_name(command_name), "Invalid command name: '%s'." % command_name)
	assert(callable.is_valid(), "Invalid Callable for command '%s'." % command_name)

	var method_info: Dictionary = object_find_method_info(callable.get_object(), callable.get_method())
	if method_info.is_empty():
		return push_error("Method '%s' not found for command '%s'." % [callable.get_method(), command_name])

	var args: Array = method_info.args
	if not is_valid_args(args):
		return push_error("Unsupported argument types in method '%s'." % callable.get_method())

	var arg_names: PackedStringArray = PackedStringArray()
	var arg_types: PackedInt32Array = PackedInt32Array()
	init_arg_types_and_names(args, arg_types, arg_names)

	var command: Dictionary[StringName, Variant] = {
		&"name": command_name,
		&"object_id": callable.get_object_id(),
		&"method": callable.get_method(),
		&"description": description,
		&"arg_types": arg_types,
		&"arg_names": arg_names,
		&"default_args": method_info.default_args,
	}
	command.make_read_only()

	_commands[command_name] = command
	_command_list.clear()


## Print string to the console.
func print(string: String) -> void:
	printed_line.emit(string + "\n")

func validate_argument_count(args: PackedStringArray, cmd: Dictionary) -> bool:
	var expected_max: int = len(cmd.arg_types)
	var expected_min: int = expected_max - len(cmd.default_args)

	if args.size() < expected_min or args.size() > expected_max:
		var error_message: String = ""
		if cmd.default_args:
			error_message = "[color=RED]Invalid argument count: Expected between %d and %d, received %d.[/color]" % [expected_min, expected_max, args.size()]
		else:
			error_message = "[color=RED]Invalid argument count: Expected %d, received %d.[/color]" % [expected_max, args.size()]

		self.print(error_message)
		return false

	return true

## Execute command. First word must be a command name, other is arguments.
func execute(string: String) -> void:
	var args: PackedStringArray = string.split(" ", false)
	if args.is_empty():
		return

	_history.push_back(string)
	_history_index = _history.size()

	self.print("[color=GRAY]> " + string + "[/color]")

	if not has_command(args[0]):
		return self.print("[color=RED]Command \"" + string + "\" not found.[/color]")

	var cmd: Dictionary = _commands[args[0]]
	if not is_instance_id_valid(cmd.object_id):
		return self.print("[color=RED]Invalid object instance.[/color]")

	args.remove_at(0) # Remove command name from arguments.
	if not validate_argument_count(args, cmd):
		return

	var result: Variant = null
	if cmd.arg_types: # If command has arguments.
		var arg_array: Array = []
		arg_array.resize(args.size())

		for i: int in args.size():
			var value: Variant = convert_string(args[i], cmd.arg_types[i])
			if value == null:
				return self.print("[color=YELLOW]Invalid argument type: Cannot convert argument " + str(i + 1) + " from \"String\" to \"" + type_string(cmd.arg_types[i]) + "\".[/color]")

			arg_array[i] = value

		result = instance_from_id(cmd.object_id).callv(cmd.method, arg_array)
	else:
		result = instance_from_id(cmd.object_id).call(cmd.method)

	if result is String:
		self.print(result)

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
		_command_list = _commands.keys()
		_command_list.sort()

	return _command_list

## Return autocomplete command.
func autocomplete_command(string: String, selected_index: int = -1) -> String:
	if string.is_empty():
		return string

	var i: int = 0
	for cmd: String in get_command_list():
		if not cmd.begins_with(string):
			continue
		elif i == selected_index:
			return cmd + " " # A space at the end of a line for convenience.

		i += 1

	return string

## Return a list of autocomplete commands.
func autocomplete_list(string: String, selected_index: int = -1) -> PackedStringArray:
	var list := PackedStringArray()
	if string.is_empty():
		return list

	var i: int = 0
	for cmd: String in get_command_list():
		if not cmd.begins_with(string):
			continue
		elif i == selected_index:
			list.push_back("[u]" + cmd + "[/u]")
		else:
			list.push_back(cmd)

		i += 1

	return list

## Clear the console history.
func clear() -> void:
	_history.clear()
	_history_index = 0

	cleared.emit()


func _command_help() -> void:
	const TEMPLATE: String = "[cell][color=WHITE][url={0} ]{0}[/url][/color][/cell][cell][color=GRAY]{1}[/color][/cell]"

	var output: String = "[table=2]"

	for cmd: String in get_command_list():
		output += TEMPLATE.format([cmd, get_command_description(cmd)])

	self.print(output + "[/table]")




## Checks if the argument type is supported.
static func is_arg_type_supported(arg_type: int) -> bool:
	const SUPPORTED_TYPES: PackedInt32Array = [
		TYPE_NIL,
		TYPE_BOOL,
		TYPE_INT,
		TYPE_FLOAT,
		TYPE_STRING,
		TYPE_STRING_NAME,
	]

	return arg_type in SUPPORTED_TYPES

## Checks if all arguments are valid.
static func is_valid_args(args: Array[Dictionary]) -> bool:
	for arg: Dictionary in args:
		if not is_arg_type_supported(arg.type):
			return false

	return true

## Finds method info about the method of an object.
static func object_find_method_info(object: Object, method_name: String) -> Dictionary:
	var script: Script = object if object is Script else object.get_script()
	if is_instance_valid(script):
		for method: Dictionary in script.get_script_method_list():
			if method_name == method.name:
				return method

	for method: Dictionary in object.get_method_list():
		if method_name == method.name:
			return method

	return {}

## Initializes argument types and names.
static func init_arg_types_and_names(args: Array[Dictionary], types: PackedInt32Array, names: PackedStringArray) -> void:
	types.resize(args.size())
	names.resize(args.size())

	for i: int in args.size():
		types[i] = args[i][&"type"]
		names[i] = args[i][&"name"] if args[i][&"name"] else "arg%d" % i

## Converts a string to the specified type.
static func convert_string(string: String, type: int) -> Variant:
	if type == TYPE_NIL or type == TYPE_STRING or type == TYPE_STRING_NAME:
		return string # Non static argument or String/StringName return without changes.
	elif type == TYPE_BOOL:
		if string == "true":
			return true
		elif string == "false":
			return false
		elif string.is_valid_int():
			return string.to_int()
	elif type == TYPE_INT and string.is_valid_int():
		return string.to_int()
	elif type == TYPE_FLOAT and string.is_valid_float():
		return string.to_float()

	return null
