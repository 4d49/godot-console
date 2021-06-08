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

# Get the previous string from history.
func get_prev() -> String:
	_history_index = wrapi(_history_index - 1, 0, _history.size())
	return _get_string(_history_index)

# Get the next string from history.
func get_next() -> String:
	_history_index = wrapi(_history_index + 1, 0, _history.size())
	return _get_string(_history_index)


func clear_history() -> void:
	_history.clear()
	return


func _get_string(index: int) -> String:
	if _history:
		return _history[index]
	
	return ""
