# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Reference


var _command_list : Array
var _command_sort : bool

var _prev_string : String


func _init(command_list: Array) -> void:
	self.set_command_list(command_list)
	return


func set_command_list(command_list: Array) -> void:
	self._command_list = command_list
	self._command_sort = false
	return


func get_command_list() -> Array:
	if _command_sort:
		return _command_list
	
	_command_list.sort()
	_command_sort = true
	return _command_list


func get_string(text: String) -> String:
	if text:
		for string in _command_list:
			if string.begins_with(text) and string != _prev_string:
				_prev_string = string
				return string
	
	return text


func get_string_list(text: String) -> Array:
	var list : Array = []
	if text:
		for string in _command_list:
			if string.begins_with(text):
				list.append(string)
	
	return list
