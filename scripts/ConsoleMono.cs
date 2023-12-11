using System;
using System.Reflection.Metadata;
using Godot;

public partial class ConsoleMono : Node
{
	private static Node _console;

	public override void _EnterTree()
	{
		base._EnterTree();

		_console = GetNode("/root/Console");
	}

	public static bool HasCommand(StringName command)
	{
		return (bool)_console.Call("has_command", command);
	}

	public static void CreateCommand(StringName command, Delegate callable, StringName description = null)
	{
		object? target = callable.Target;
		if (target is not GodotObject godotObject)
			throw new ArgumentException("Class does not inherits GameObject or method is static");
		_console.Call("create_command", command,
			new Callable(godotObject, callable.Method.Name), description ?? "");
	}
	public static void CreateCommand(StringName command, GodotObject target, StringName callable, StringName description = null)
	{
		_console.Call("create_command", command, new Callable(target, callable), description ?? "");
	}

	public static bool RemoveCommand(StringName command)
	{
		return (bool)_console.Call("remove_command", command);
	}

	public static void Print(string line)
	{
		_console.Call("print_line", line);
	}
}
