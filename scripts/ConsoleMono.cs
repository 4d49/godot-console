// Copyright (c) 2020-2024 Mansur Isaev and contributors - MIT License
// See `LICENSE.md` included in the source distribution for details.

using System;
using Godot;

public partial class ConsoleMono : Node
{
	private static Node _console = null;

	public override void _EnterTree()
	{
		_console = GetNode("/root/Console");
	}

	public static bool HasCommand(StringName command)
	{
		return (bool)_console.Call("has_command", command);
	}
	public static bool RemoveCommand(StringName command)
	{
		return (bool)_console.Call("remove_command", command);
	}

	public static string GetCommandDescription(StringName command)
	{
		return (string)_console.Call("get_command_description", command);
	}

	public static void CreateCommand(StringName command, Delegate callable, string description = null)
	{
		if (callable.Target is not GodotObject godotObject)
			throw new ArgumentException("Class does not inherits GameObject or method is static");

		_console.Call("create_command", command, new Callable(godotObject, callable.Method.Name), description ?? "");
	}
	public static void CreateCommand(StringName command, GodotObject target, StringName methodName, string description = null)
	{
		_console.Call("create_command", command, new Callable(target, methodName), description ?? "");
	}

	public static void Print(string str)
	{
		_console.Call("print_line", str);
	}

	public static void Execute(string str)
	{
		_console.Call("execute", str);
	}

	public static string GetPrevCommand()
	{
		return (string)_console.Call("get_prev_command");
	}
	public static string GetNextCommand()
	{
		return (string)_console.Call("get_next_command");
	}

	public static string[] GetCommandList()
	{
		return (string[])_console.Call("get_command_list");
	}

	public static string AutocompleteCommand(string str, int selectedIndex = -1)
	{
		return (string)_console.Call("autocomplete_command", str, selectedIndex);
	}
	public static string[] AutocompleteList(string str, int selectedIndex = -1)
	{
		return (string[])_console.Call("autocomplete_list", str, selectedIndex);
	}

	public static void Clear()
	{
		_console.Call("clear");
	}
}
