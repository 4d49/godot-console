# Godot-Console

Simple in-game console for Godot 3.2.

![](https://i.imgur.com/5F3aStc.png)

# Features

- Installed as plugin.
- The Console is Singleton.
- History of entered commands.
- Autocomplete commands.

# Installation:

1. Clone or download this project to `addons/godot-console` folder.
2. Enabled `Godot Console` in Plugins.
3. Add `ConsoleContainer` node to the scene.
4. Profit.

# Usage:

## Register console command:

```gdscript
# player.gd
func _ready() -> void:
	var name = "tp" # The name of the console command.
	var instance = self # Object instance.
	var method = "teleport" # Method name.
	var desc = "Teleport the player to coordinates." # Command Description. Optional.
	# Register the command in the console.
	Console.create_command(name, instance, method, desc)
```

## Static typing:

```gdscript
# Arguments is float.
func teleport(x: float, y: float) -> void:
	self.position = Vector2(x, y)
```

## Dynamic typing:

```gdscript
# Arguments is String.
func teleport(x, y):
	self.position = Vector2(float(x), float(y))
```

## Optional return String for print result to the console.

```gdscript
func add_money(value: int) -> String:
	self.money += value
	return "Player money:%s" % money
```

# License

Copyright © 2020 Mansur Isaev and contributors

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE.md](LICENSE.md) for more information.
