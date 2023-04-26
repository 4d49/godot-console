# Copyright (c) 2020-2023 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@tool
## Default container for Console output/input.
class_name ConsoleContainer
extends VBoxContainer


var _console : ConsoleNode

var _console_output : RichTextLabel
var _console_input : LineEdit

var _tooltip_panel : PanelContainer
var _tooltip_label : Label


func _init() -> void:
	_console_output = RichTextLabel.new()
	_console_output.size_flags_vertical = SIZE_EXPAND_FILL
	_console_output.scroll_following = true
	_console_output.selection_enabled = true
	_console_output.focus_mode = Control.FOCUS_NONE
	self.add_child(_console_output, false, Node.INTERNAL_MODE_FRONT)

	_console_input = LineEdit.new()
	_console_input.context_menu_enabled = false
	_console_input.clear_button_enabled = true
	_console_input.caret_blink = true
	_console_input.placeholder_text = "Command"
	_console_input.clear_button_enabled = true
	_console_input.editable = false

	var error := _console_input.text_changed.connect(set_input_text)
	assert(error == OK, error_string(error))

	error = _console_input.gui_input.connect(_on_input_gui_event)
	assert(error == OK, error_string(error))

	self.add_child(_console_input, false, Node.INTERNAL_MODE_FRONT)

	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.set_theme_type_variation(&"TooltipPanel")
	_tooltip_panel.set_v_grow_direction(Control.GROW_DIRECTION_BEGIN)
	_tooltip_panel.set_offset(SIDE_LEFT, 4.0)
	_tooltip_panel.set_offset(SIDE_BOTTOM, -4.0)
	_tooltip_panel.hide()
	_console_input.add_child(_tooltip_panel)

	_tooltip_label = Label.new()
	_tooltip_label.set_theme_type_variation(&"TooltipLabel")
	_tooltip_panel.add_child(_tooltip_label)


func _enter_tree() -> void:
	set_console(get_node_or_null("/root/Console"))


func _exit_tree() -> void:
	set_console(null)


func set_console(console: ConsoleNode) -> void:
	if is_same(_console, console):
		return

	if is_instance_valid(_console):
		if _console.printed_line.is_connected(_console_output.append_text):
			_console.printed_line.disconnect(_console_output.append_text)

		if _console.cleared.is_connected(_console_output.clear):
			_console.cleared.disconnect(_console_output.clear)

	if is_instance_valid(console):
		if not console.printed_line.is_connected(_console_output.append_text):
			var error := console.printed_line.connect(_console_output.append_text)
			assert(error == OK, error_string(error))

		if not console.cleared.is_connected(_console_output.clear):
			var error := console.cleared.connect(_console_output.clear)
			assert(error == OK, error_string(error))

	_console = console
	_console_input.editable = is_instance_valid(_console)


func get_console() -> ConsoleNode:
	return _console


func set_input_text(text: String) -> void:
	_console_input.text = text
	_console_input.caret_column = text.length()

	var autocomplete := PackedStringArray() if text.is_empty() else _console.autocomplete_list(text)

	if autocomplete.is_empty():
		_tooltip_panel.hide()
	else:
		_tooltip_label.set_text("\n".join(autocomplete))
		_tooltip_panel.show()


func _on_input_gui_event(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_text_completion_accept"):
		_console.execute(_console_input.text)
		_console_input.clear()
	elif event.is_action_pressed(&"ui_text_indent"):
		set_input_text(_console.autocomplete_command(_console_input.text))
	elif event.is_action_pressed(&"ui_text_caret_up"):
		set_input_text(_console.get_prev_command())
	elif event.is_action_pressed(&"ui_text_caret_down"):
		set_input_text(_console.get_next_command())
	else:
		return

	_console_input.accept_event()
