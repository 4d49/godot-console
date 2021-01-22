# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Reference


const argBool   = preload("console_arguments.gd").argBool
const argInt    = preload("console_arguments.gd").argInt
const argFloat  = preload("console_arguments.gd").argFloat
const argString = preload("console_arguments.gd").argString

const BOOL   := TYPE_BOOL
const INT    := TYPE_INT
const FLOAT  := TYPE_REAL
const STRING := TYPE_STRING

const INVALID_ARGUMENT_COUNT = "Command must have %s arguments."
const INVALID_ARGUMENT_TYPE = "Arguments must be of type: %s"


var _name : String
var _func : FuncRef
var _desc : String
var _types : Array


func _init(name: String, f_ref: FuncRef, desc: String = "", args: PoolIntArray = []) -> void:
	self._set_name(name)
	self._set_func(f_ref)
	self._set_desc(desc)
	self._set_types(args)
	return


func _to_string() -> String:
	return "%s- %s" % [get_name(), get_desc()]


func get_name() -> String:
	return _name


func get_desc() -> String:
	return _desc


func has_argrument() -> bool:
	return _types.size() > 0


func get_argument_count() -> int:
	return _types.size()


func get_argument_names() -> String:
	var string : PoolStringArray
	for type in _get_types():
		string.append(type.get_name())
	
	return string.join(", ")


func execute(pool_string: PoolStringArray = []) -> String:
	var execute_result # Returned value by FuncRef.
	
	if get_argument_count() != pool_string.size():
		return INVALID_ARGUMENT_COUNT % get_argument_count()
	
	if has_argrument():
		var args : Array
		args.resize(get_argument_count())
		
		var idx = 0
		for type in _get_types():
			var string = pool_string[idx]
			
			if not type.is_valid(string):
				return INVALID_ARGUMENT_TYPE % get_argument_names()
			
			args[idx] = type.convert_string(string)
			idx += 1
		
		execute_result = _get_func().call_funcv(args)
	else:
		execute_result = _get_func().call_func()
	
	# Return result to the console if is a string.
	if execute_result is String:
		return execute_result
	
	return ""


func _set_name(name: String) -> void:
	assert(name, "Console command name cannot be empty.")
	_name = name
	return


func _set_func(func_ref: FuncRef) -> void:
	assert(func_ref.is_valid(), "Invalid function reference.")
	_func = func_ref
	return


func _get_func() -> FuncRef:
	return _func


func _set_desc(desc: String) -> void:
	if desc.empty():
		desc = "No description."
	
	_desc = desc
	return


func _set_types(pool_types: PoolIntArray) -> void:
	var types : Array
	types.resize(pool_types.size())
	
	var idx = 0
	for type in pool_types:
		var arg_type
		match type:
			BOOL:
				arg_type = argBool
			INT:
				arg_type = argInt
			FLOAT:
				arg_type = argFloat
			STRING:
				arg_type = argString
			_:
				assert(false, "Unsupported type.")
		
		types[idx] = arg_type
		idx += 1
	
	_types = types
	return


func _get_types() -> Array:
	return _types
