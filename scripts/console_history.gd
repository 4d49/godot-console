# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Reference


var _history : Array
var _history_index : int # Used to iterate over history.

# Add string to history.
func add_string(input: String) -> void:
	if input:
		_history.append(input)
		_history_index = _history.size()
	
	return


func set_index(index: int) -> void:
	if index < 0:
		_history_index = _history.size() - 1
	elif index > _history.size() - 1:
		_history_index = 0
	else:
		_history_index = index
	return


func get_index() -> int:
	return _history_index

# Get the previous string from history.
func get_prev() -> String:
	set_index(get_index() - 1)
	return get_string(get_index())

# Get the next string from history.
func get_next() -> String:
	set_index(get_index() + 1)
	return get_string(get_index())

# Get history string by index.
func get_string(index: int) -> String:
	if _history.empty():
		return ""
	
	if index < 0:
		return _history.pop_front()
	
	if index > _history.size() - 1:
		return _history.pop_back()
	
	return _history[index]


func clear_history() -> void:
	_history.clear()
	return
