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
			self.push_color(color)
			self.add_text(text)
			self.newline()
		
		return


class ConsoleInput extends LineEdit:
	func _init() -> void:
		self.context_menu_enabled = false
		self.clear_button_enabled = true
		self.caret_blink = true
		self.placeholder_text = "Command"
		self.clear_button_enabled = true
		
		self.connect("text_entered", self, "_on_text_entered")
		return
	
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed:
			if event.shift and event.scancode == KEY_TAB:
				var autocomplete = Console.get_autocomplete(text)
				set_text(autocomplete)
				accept_event()
			elif event.control:
				match event.scancode:
					KEY_UP:
						var prev = Console.get_prev_command()
						set_text(prev)
					KEY_DOWN:
						var next = Console.get_next_command()
						set_text(next)
					_:
						return
				accept_event()
		return
	
	func set_text(text: String) -> void:
		self.text = text
		self.caret_position = text.length()
		return
	
	func _on_text_entered(text: String) -> void:
		Console.write_command(text)
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
