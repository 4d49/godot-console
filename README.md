# Godot-Console

Simple in-game console for Godot 4.0.

![](https://user-images.githubusercontent.com/8208165/144989905-6d3eb45d-26e7-4acd-9a53-c31d7e49c400.png)

# Features

- Installed as plugin.
- The Console is Singleton.
- History of entered commands.
- Autocomplete commands.
- Static typing.

# Installation:

1. Clone this repository to `addons` folder.
2. Enabled `Godot Console` in Plugins.
3. Add `ConsoleContainer` node to the scene.
4. Profit.

# Usage:

## Create console command:

```gdscript
# player.gd
func teleport(x: float, y: float) -> void:
	self.position = Vector2(x, y)

func _ready() -> void:
	Console.create_command("tp", self.teleport, "Teleport the player.")
```

## Static typing:

With static typing, Console will try to cast arguments to a supported type.
```gdscript
# Arguments is float.
func teleport(x: float, y: float) -> void:
	self.position = Vector2(x, y)
```

## Dynamic typing:

With dynamic typing, Console will NOT cast arguments to type, and arguments will be a String.
```gdscript
# Arguments is Strings.
func teleport(x, y):
	# Convert arguments to float.
	self.position = Vector2(x.to_float(), y.to_float())
```

## Optional return string for print result to the console.

```gdscript
func add_money(value: int) -> String:
	self.money += value
	# Prints: Player money:42
	return "Player money:%d" % money
```

# License

Copyright (c) 2020-2022 Mansur Isaev and contributors

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE.md](LICENSE.md) for more information.
