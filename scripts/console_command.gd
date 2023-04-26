# Copyright (c) 2020-2023 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Base ConsoleCommand class.
class_name ConsoleCommand
extends RefCounted


var _name : StringName
var _desc : String

var _object_id : int
var _method : StringName

var _arg_names : PackedStringArray
var _arg_types : PackedInt32Array

## Return name of type.
static func get_type_name(type: int) -> String:
	match type:
		TYPE_BOOL:
			return "bool"
		TYPE_INT:
			return "int"
		TYPE_FLOAT:
			return "float"
		TYPE_STRING:
			return "String"
		TYPE_STRING_NAME:
			return "StringName"

	return ""


func _get_method_info(object: Object, method: String) -> Dictionary:
	var script := object.get_script() as Script
	if script:
		for m in script.get_script_method_list():
			if method == m["name"]:
				return m

	for m in object.get_method_list():
		if method == m["name"]:
			return m

	return {}


func _init_arguments(object: Object, method: String) -> void:
	var method_info : Dictionary = _get_method_info(object, method)

	assert(method_info, "Method not found.")
	if method_info.is_empty():
		return

	var args : Array[Dictionary] = method_info["args"]

	var error := _arg_names.resize(args.size())
	assert(error == OK, error_string(error))

	error = _arg_types.resize(args.size())
	assert(error == OK, error_string(error))

	for i in args.size():
		var arg : Dictionary = args[i]

		assert(is_valid_type(arg["type"]), "Invalid argument type.")
		if not is_valid_type(arg["type"]):
			continue

		_arg_types[i] = arg["type"]

		if arg["name"]: # Debug build.
			_arg_names[i] = arg["name"]
		else: # Release build.
			_arg_names[i] = "arg" + str(i)


func _init(name: StringName, callable: Callable, desc: String) -> void:
	assert(name != StringName(), "Invalid name.")
	_name = name
	_desc = desc

	assert(callable.is_valid(), "Invalid Callable.")
	assert(callable.is_standard(), "Custom Callable is not supported.")
	_object_id = callable.get_object_id()
	_method = callable.get_method()

	_init_arguments(instance_from_id(_object_id), _method)

## Return [param true] if type is valid.
func is_valid_type(type: int) -> bool:
	match type:
		TYPE_NIL: # Non static.
			return true
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT:
			return true
		TYPE_STRING, TYPE_STRING_NAME:
			return true

	return false

## Return command name.
func get_name() -> StringName:
	return _name

## Return command description.
func get_description() -> String:
	return _desc

## Return object instance id.
func get_object_id() -> int:
	return _object_id

## Return Object.
func get_object() -> Object:
	return instance_from_id(get_object_id())

## Return the name of the method.
func get_method() -> StringName:
	return _method

## Return the argument name.
func get_argument_name(index: int) -> String:
	return _arg_names[index]

## Return the argument type.
func get_argument_type(index: int) -> int:
	return _arg_types[index]

## Return the command arguments count.
func get_argument_count() -> int:
	return _arg_types.size()

## Return [param true] if command has arguments.
func has_argument() -> bool:
	return get_argument_count() > 0

## Return [param true] if the command is valid.
func is_valid() -> bool:
	return is_instance_id_valid(_object_id)

## Return converted the string to valid type or null.
func convert_string(string: String, type: int) -> Variant:
	assert(is_valid_type(type), "Invalid type.")
	if not is_valid_type(type):
		return null

	if type == TYPE_NIL or type == TYPE_STRING or type == TYPE_STRING_NAME:
		return string # Non static argument or String return without changes.
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

## Execute the command and return the result [String].
func execute(arguments: PackedStringArray) -> String:
	if not is_valid():
		return "[color=RED]Invalid object instance.[/color]"

	if get_argument_count() != arguments.size():
		return "[color=RED]Invalid argument count: Expected " + str(get_argument_count()) + ", received " + str(arguments.size()) + ".[/color]"

	var result = null
	if has_argument():
		var arg_array : Array = []

		var error := arg_array.resize(get_argument_count())
		assert(error == OK, error_string(error))

		for i in get_argument_count():
			var value = convert_string(arguments[i], get_argument_type(i))

			if value == null:
				return "[color=YELLOW]Invalid argument type: Cannot convert argument " + str(i + 1) + " from \"String\" to \"" + ConsoleCommand.get_type_name(get_argument_type(i)) + "\".[/color]"

			arg_array[i] = value

		result = get_object().callv(get_method(), arg_array)
	else:
		result = get_object().call(get_method())

	return result if result is String else ""
