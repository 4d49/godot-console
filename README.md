# Godot-Console

Simple in-game console for Godot 4.x.

![](https://user-images.githubusercontent.com/8208165/144989905-6d3eb45d-26e7-4acd-9a53-c31d7e49c400.png)

## Features

- Installed as plugin
- Singleton implementation
- Command history navigation (Up/Down keys)
- Tab-based command autocompletion
- Argument type conversion for static typing
- Built-in `clear` and `help` commands
- C# support via bindings
- Rich text formatting support

## Installation

1. Clone this repository to your project's `addons` folder:
   ```bash
   git clone https://github.com/4d49/godot-console.git
   ```
   Or download the latest [release](https://github.com/4d49/godot-console/releases/latest/download/godot-console.zip)
2. Enable the plugin in Godot: **Project Settings → Plugins → Enable `Godot Console`**
3. Add the `ConsoleContainer` node to your main scene

## Usage

### Creating Commands
Register commands using `Console.create_command()`:

```gdscript
# player.gd
func teleport(x: float, y: float) -> void:
    position = Vector2(x, y)

func _ready() -> void:
    # Register command: name, callback, description
    Console.create_command("tp", teleport, "Teleport player to coordinates")
```

### Static Typing
Arguments are automatically converted to specified types:

```gdscript
# Arguments auto-converted to float
func teleport(x: float, y: float) -> void:
    position = Vector2(x, y)
```

**Supported Types:** `bool`, `int`, `float`, `String`, `StringName`

### Dynamic Typing
Arguments are passed as raw strings:

```gdscript
# Arguments received as Strings
func teleport(x, y):
    position = Vector2(x.to_float(), y.to_float())
```

### Returning Results
Return a String to display results in console:

```gdscript
func add_money(amount: int) -> String:
    money += amount
    return "Added money: %d (Total: %d)" % [amount, money]
```

### Navigation
- **Up/Down arrows**: Browse command history
- **Shift + Tab**: Autocomplete commands
- **Enter**: Execute command

## C# Bindings
Add `addons/godot-console/scripts/ConsoleMono.cs` to Autoloads after `Console`.

```csharp
public partial class Player : CharacterBody2D
{
    private void Teleport(float x, float y)
    {
        Position = new Vector2(x, y);
    }

    public override void _Ready()
    {
        // Register command directly
        ConsoleMono.CreateCommand("tp", Teleport);

        // Alternative registration
        ConsoleMono.CreateCommand("teleport", this, MethodName.Teleport);
    }
}
```

## Best Practices
1. Use explicit type hints for arguments
2. Validate user input in command handlers
3. Return meaningful success/error messages
4. Keep command names short and descriptive
5. Use `warning()`/`error()` for status messages:
   ```gdscript
   Console.warning("Low health!")
   Console.error("Invalid coordinates!")
   ```

## License

Copyright (c) 2020-2025 Mansur Isaev and contributors

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE.md](LICENSE.md) for more information.
