# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Reference


var _name : String
var _desc : String

var _object : Object
var _method : String

var _names : PoolStringArray
var _types : PoolIntArray


static func get_type_name(type: int) -> String:
	match type:
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "bool"
		TYPE_INT:
			return "int"
		TYPE_REAL:
			return "float"
		TYPE_STRING:
			return "String"
		TYPE_VECTOR2:
			return "Vector2"
		TYPE_RECT2:
			return "Rect2"
		TYPE_VECTOR3:
			return "Vector3"
		TYPE_TRANSFORM2D:
			return "Transform2D"
		TYPE_PLANE:
			return "Plane"
		TYPE_QUAT:
			return "Quat"
		TYPE_AABB:
			return "AABB"
		TYPE_BASIS:
			return "Basis"
		TYPE_TRANSFORM:
			return "Transform"
		TYPE_COLOR:
			return "Color"
		TYPE_NODE_PATH:
			return "NodePath"
		TYPE_RID:
			return "RID"
		TYPE_OBJECT:
			return "Object"
		TYPE_DICTIONARY:
			return "Dictionary"
		TYPE_ARRAY:
			return "Array"
		TYPE_RAW_ARRAY:
			return "PoolByteArray"
		TYPE_INT_ARRAY:
			return "PoolIntArray"
		TYPE_REAL_ARRAY:
			return "PoolRealArray"
		TYPE_STRING_ARRAY:
			return "PoolStringArray"
		TYPE_VECTOR2_ARRAY:
			return "PoolVector2Array"
		TYPE_VECTOR3_ARRAY:
			return "PoolVector3Array"
		TYPE_COLOR_ARRAY:
			return "PoolColorArray"
		_:
			assert(false, "Invalid type.")
			return ""


func _init(name: String, desc: String, obj: Object, method: String, args: Array) -> void:
	self._set_name(name)
	self._set_desc(desc)
	self._set_object(obj)
	self._set_method(method)
	self._set_args(args)
	return


func _to_string() -> String:
	return "%s- %s" % [get_name(), get_desc()]


func get_name() -> String:
	return _name


func get_desc() -> String:
	var desc = _desc
	
	if has_argument():
		var arg_string = " Argument's: " + get_argument_string()
		desc += arg_string
	
	return desc


func get_object() -> Object:
	return _object


func get_method() -> String:
	return _method


func get_argument_name(index: int) -> String:
	return _names[index]


func get_argument_type(index: int) -> int:
	return _types[index]


func get_argument_string() -> String:
	var pool : PoolStringArray = []
	
	for i in get_argument_count():
		var name = get_argument_name(i)
		var type = get_argument_type(i)
		
		if type:
			var type_name = get_type_name(type)
			pool.append(name + "(" + type_name + ")")
		else:
			pool.append(name)
	
	return pool.join(", ") + "."


func has_argument() -> bool:
	return not _names.empty()


func get_argument_count() -> int:
	return _names.size()


func is_valid_argument_count(count: int) -> bool:
	return get_argument_count() == count


func is_valid_string(arg: String, type: int) -> bool:
	match type:
		TYPE_BOOL:
			return arg == "true" or arg == "false" or arg.is_valid_integer()
		TYPE_INT, TYPE_REAL:
			return arg.is_valid_float()
		TYPE_NIL, TYPE_STRING:
			return true
		_:
			return false


func convert_string(arg: String, type: int): # Return Variant.
	match type:
		TYPE_BOOL:
			return bool(str2var(arg))
		TYPE_INT, TYPE_REAL:
			return convert(arg, type)
		TYPE_NIL, TYPE_STRING:
			return arg
		_:
			assert(false, "Invalid type.")
			return null


func execute(pool_string: PoolStringArray = []) -> String:
	if is_valid_argument_count(pool_string.size()):
		var execute_result # Returned value by call method.
		
		var object = get_object()
		var method = get_method()
		
		if has_argument():
			var args : Array = []
			args.resize(get_argument_count())
			
			for i in args.size():
				var string = pool_string[i]
				var type = get_argument_type(i)
				
				if is_valid_string(string, type):
					var value = convert_string(string, type)
					args[i] = value
				else:
					return "Invalid type of arguments: " + get_argument_string()
			
			execute_result = object.callv(method, args)
		else:
			execute_result = object.call(method)
		
		# Return the result to the console.
		return execute_result
	else:
		return "The command must have '%s' arguments: " % get_argument_count() + get_argument_string()


func _set_name(name: String) -> void:
	assert(name, "Invalid name.")
	_name = name
	return


func _set_desc(desc: String) -> void:
	if desc.empty():
		desc = "No description."
	
	_desc = desc
	return


func _set_object(object: Object) -> void:
	assert(object, "Invalid Object")
	_object = object
	return


func _set_method(method: String) -> void:
	assert(method, "Invalid Method")
	_method = method
	return


func _set_args(args: Array) -> void:
	if args:
		var size = args.size()
		
		_names.resize(size)
		_types.resize(size)
		
		for i in size:
			var arg = args[i]
			
			_names[i] = arg.name
			_types[i] = arg.type
	
	return
