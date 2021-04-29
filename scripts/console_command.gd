# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Reference


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


func str2arg(string: String, type: int):
	var value
	match type:
		BOOL:
			value = bool(str2var(string))
		INT:
			value = int(string)
		FLOAT:
			value = float(string)
		STRING:
			value = string
		_:
			assert(false, "Invalid Type")
	
	return value


func execute(pool_string: PoolStringArray = []) -> String:
	var execute_result # Returned value by FuncRef.
	
	if get_argument_count() != pool_string.size():
		return INVALID_ARGUMENT_COUNT % get_argument_count()
	
	if has_argrument():
		var args : Array
		args.resize(get_argument_count())
		
		var idx = 0
		for type in _get_types():
			args[idx] = str2arg(pool_string[idx], type)
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
	_types = pool_types
	return


func _get_types() -> Array:
	return _types
