# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends VBoxContainer


class ConsoleOutput extends RichTextLabel:
	# Default color for console text.
	const DEFAULT_COLOR := Color.gray
	
	func _init() -> void:
		self.size_flags_vertical = SIZE_EXPAND_FILL
		self.size_flags_horizontal = SIZE_EXPAND_FILL
		self.scroll_following = true
		self.selection_enabled = true
		self.rect_min_size = Vector2(128, 128)
		self.focus_mode = Control.FOCUS_NONE
		return
	
	func _ready() -> void:
		if Engine.is_editor_hint():
			return
		
		Console.connect("message", self, "_print_line")
		Console.create_command("clear", self, "clear", "Clear console output")
		return
	
	func _print_line(text: String, color : Color = DEFAULT_COLOR) -> void:
		if text:
			self.newline()
			self.push_color(color)
			self.add_text(text)
		
		return


class ConsoleInput extends LineEdit:
	func _init() -> void:
		self.context_menu_enabled = false
		self.clear_button_enabled = true
		self.caret_blink = true
		self.placeholder_text = "Command"
		self.clear_button_enabled = true
		return
	
	func _gui_input(event: InputEvent) -> void:
		if Input.is_key_pressed(KEY_ENTER):
			_enter_text()
		
		elif Input.is_key_pressed(KEY_UP):
			set_text(Console.get_prev_command())
		
		elif Input.is_key_pressed(KEY_DOWN):
			set_text(Console.get_next_command())
		
		elif Input.is_key_pressed(KEY_TAB):
			set_text(Console.get_autocomplete(text))
		
		return
	
	func set_text(text: String) -> void:
		.set_text(text)
		caret_position = text.length()
		return
	
	func _enter_text() -> void:
		Console.write_command(self.text)
		self.clear()
		return


var _console_output : ConsoleOutput
var _console_input  : ConsoleInput


func _init() -> void:
	self.focus_mode = FOCUS_NONE
	
	_console_output = ConsoleOutput.new()
	self.add_child(_console_output)
	
	_console_input = ConsoleInput.new()
	self.add_child(_console_input)
	
	return
