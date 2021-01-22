# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node


signal message(text)


const ConsoleCommand = preload("console_command.gd")
const ConsoleHistory = preload("console_history.gd")
const ConsoleAutocomplite = preload("console_autocomplete.gd")

const BOOL   : int = ConsoleCommand.BOOL
const INT    : int = ConsoleCommand.INT
const FLOAT  : int = ConsoleCommand.FLOAT
const STRING : int = ConsoleCommand.STRING


var _console_command : Dictionary
var _console_history : ConsoleHistory
var _console_autocomplete : ConsoleAutocomplite


func _init() -> void:
	_console_history = ConsoleHistory.new()
	_console_autocomplete = ConsoleAutocomplite.new()
	
	create_command("help", self, "_command_help", "Show all console command")
	create_command("version", self, "_command_version", "Show Engine version")
	create_command("test", self, "_command_test", "Test console output")
	create_command("print", self, "_command_print", "Print string to console", [STRING])
	create_command("add", self, "_command_add", "Adds two numbers", [FLOAT, FLOAT])
	create_command("subtract", self, "_command_subtract", "Subtract two number", [FLOAT, FLOAT])
	create_command("quit", self, "_command_quit", "Quit from game")
	return


func has_command(name: String) -> bool:
	return _get_commands().has(name)

# Create a new console command.
func create_command(
	name: String,
	instance: Object,
	funcname: String,
	desc: String = "",
	args: PoolIntArray = []
	) -> void:
	
	assert(not has_command(name), "The console has a '%s' command" % name)
	_get_commands()[name] = ConsoleCommand.new(name, funcref(instance, funcname), desc, args)
	_get_autocomplete().set_commands(_get_commands().keys())
	
	return

# Write a console command.
func write_command(input: String) -> void:
	if input.empty():
		return
	
	_get_history().add_string(input)
	
	var args : PoolStringArray = input.split(" ", false)
	var name : String = args[0]
	
	args.remove(0) # Remove command name from arguments.
	
	self.print_line("-> " + input) # Print in console input string.
	
	if has_command(name):
		var output = _get_command(name).execute(args)
		self.print_line(output)
		return
	
	self.print_line("Console command '%s' not found." % name)
	return

# Print a line to the console.
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


func _get_command(name: String) -> ConsoleCommand:
	assert(has_command(name), "Console command '%s' not found" % name)
	return _get_commands().get(name)


func _get_commands() -> Dictionary:
	return _console_command


func _get_history() -> ConsoleHistory:
	return _console_history


func _get_autocomplete() -> ConsoleAutocomplite:
	return _console_autocomplete


func _command_help() -> void:
	var string : String
	
	var command : ConsoleCommand
	for i in _get_commands():
		command = _get_command(i)
		self.print_line(command.to_string())
	
	return


func _command_version() -> String:
	return "Godot Engine {major}.{minor}.{patch}".format(Engine.get_version_info())


func _command_test() -> String:
	return "Quick brown fox jumps over the lazy dog."


func _command_print(text: String) -> String:
	return text


func _command_add(a: float, b: float) -> String:
	return "Result: " + str(a + b)


func _command_subtract(a: float, b: float) -> String:
	return "Result: " + str(a - b)


func _command_quit() -> void:
	get_tree().quit()
	return
