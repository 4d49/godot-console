# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Reference


const ConsoleCommand = preload("console_command.gd")


static func is_valid_type(type: int) -> bool:
	match type:
		TYPE_BOOL, TYPE_INT, TYPE_REAL:
			return true
		TYPE_NIL, TYPE_STRING:
			return true
		_:
			return false


static func is_valid_arg(args: Array) -> bool:
	for arg in args:
		var type = arg.type
		if not is_valid_type(type):
			return false
	
	return true


static func _get_method(method_list: Array, method_name: String) -> Dictionary:
	for method in method_list:
		var name = method.name
		if name == method_name:
			return method
	
	return {}


static func _get_arg(method: Dictionary) -> Array:
	var args : Array = method.args
	
	var result : Array = []
	result.resize(args.size())
	
	for i in args.size():
		var arg = args[i]
		
		var arg_name = arg.name
		var arg_type = arg.type
		
		result[i] = {"name": arg_name, "type": arg_type}
	
	return result


static func get_method_arg(object: Object, method_name: String) -> Array:
	var object_method = _get_method(object.get_method_list(), method_name)
	var object_args = _get_arg(object_method)
	
	if object_args:
		var script : Script = object.get_script()
		if script:
			var script_method = _get_method(script.get_script_method_list(), method_name)
			if script_method:
				var script_args = _get_arg(script_method)
				if script_args:
					for i in object_args.size():
						var o_arg = object_args[i]
						var s_arg = script_args[i]
						# The object does not contain info about the arg type.
						# So take info from the script object.
						o_arg.type = s_arg.type
	
	return object_args


static func create(name: String, object: Object, method: String, desc: String) -> ConsoleCommand:
	var arg = get_method_arg(object, method)
	
	if is_valid_arg(arg):
		var command = ConsoleCommand.new(name, desc, object, method, arg)
		return command
	else:
		assert(false, "Invalid argument type.")
		return null
