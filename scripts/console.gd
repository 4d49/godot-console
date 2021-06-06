# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node


signal message(text)


const ConsoleCommand = preload("console_command.gd")
const ConsoleCommandCreator = preload("console_command_creator.gd")
const ConsoleHistory = preload("console_history.gd")
const ConsoleAutocomplite = preload("console_autocomplete.gd")


var _console_command : Dictionary
var _console_history : ConsoleHistory
var _console_autocomplete : ConsoleAutocomplite


func _init() -> void:
	create_command("fps", Engine, "set_target_fps", "The desired frames per second. A value of 0 means no limit.")
	create_command("vsync", OS, "set_use_vsync", "If true, vertical synchronization (Vsync) is enabled.")
	create_command("fullscreen", OS, "set_window_fullscreen", "If true, the window is fullscreen.")
	
	create_command("help", self, "_command_help", "Show all console command.")
	create_command("version", self, "_command_version", "Show Engine version.")
	create_command("test", self, "_command_test", "Test console output.")
	create_command("print", self, "_command_print", "Print string to console.")
	create_command("add", self, "_command_add", "Adds two numbers.")
	create_command("subtract", self, "_command_subtract", "Subtract two number.")
	create_command("quit", self, "_command_quit", "Quit the game.")
	return


func has_command(name: String) -> bool:
	return _console_command.has(name)


func is_valid_name(name: String) -> bool:
	return name.is_valid_identifier()

# Create a new console command.
func create_command(name: String, object: Object, method: String, desc: String = "") -> void:
	if has_command(name):
		assert(false, "The console has the '%s' command." % name)
	
	elif is_valid_name(name):
		assert(object, "Invalid Object.")
		assert(object.has_method(method), "Object has no method '%s'." % method)
		if object and object.has_method(method):
			var command = ConsoleCommandCreator.create(name, object, method, desc)
			
			if command:
				_add_command(command)
			else:
				assert(false, "Invalid ConsoleCommand.")
	
	else:
		assert(false, "Invalid command name.")
	
	return

# Enter the console command.
func enter_command(input: String) -> void:
	var args : PoolStringArray = input.split(" ", false)
	if args:
		var history = _get_history()
		history.add_string(input)
		
		var name : String = args[0]
		args.remove(0) # Remove command name from arguments.
		
		self.print_line("> " + input) # Print in console input string.
		
		if has_command(name):
			var command = _get_command(name)
			var result = command.execute(args) # Execution result.
			
			if result is String:
				self.print_line(result)
		else:
			self.print_line("The console command '%s' not found" % name)
	
	return

# Print the line to the console.
func print_line(input: String) -> void:
	if input:
		emit_signal("message", input)
	
	return

# Return the previus console command.
func get_prev_command() -> String:
	return _get_history().get_prev()

# Return the next console command.
func get_next_command() -> String:
	return _get_history().get_next()

# Return autocomplete cosnole command.
func get_autocomplete(text: String) -> String:
	return _get_autocomplete().get_string(text)


func get_autocomplete_list(text: String) -> Array:
	return _get_autocomplete().get_string_list(text)


func get_command_list() -> Array:
	return _get_autocomplete().get_command_list()


func _get_command(name: String) -> ConsoleCommand:
	return _console_command[name]


func _add_command(command: ConsoleCommand) -> void:
	var name = command.get_name()
	_console_command[name] = command
	return


func _get_history() -> ConsoleHistory:
	if _console_history:
		return _console_history
	
	_console_history = ConsoleHistory.new()
	return _console_history


func _get_autocomplete() -> ConsoleAutocomplite:
	if _console_autocomplete:
		return _console_autocomplete
	
	var command_list = _console_command.keys()
	_console_autocomplete = ConsoleAutocomplite.new(command_list)
	return _console_autocomplete


func _command_help() -> void:
	var list  = get_command_list()
	
	for i in list:
		var command = _get_command(i)
		self.print_line(command.to_string())
	
	return


func _command_version() -> String:
	return "Godot Engine {major}.{minor}.{patch}".format(Engine.get_version_info())


func _command_test() -> String:
	return "The quick brown fox jumps over the lazy dog."


func _command_print(text: String) -> void:
	self.print_line(text)


func _command_add(a: float, b: float) -> String:
	return "Result: " + str(a + b)


func _command_subtract(a: float, b: float) -> String:
	return "Result: " + str(a - b)


func _command_quit() -> void:
	get_tree().quit()
	return
