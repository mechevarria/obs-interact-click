# obs-interact-click

An OBS Studio Lua script for automating interact/click behavior in OBS.

## Project Overview

This is an OBS Studio script written in Lua. It hooks into OBS's scripting API to provide automated interaction or click functionality within OBS scenes/sources.

## Tech Stack

- **Language**: Lua 5.1 (OBS embeds LuaJIT / Lua 5.1)
- **Runtime**: OBS Studio scripting engine
- **APIs**: OBS Lua scripting API (`obslua` / `obs` module)

## OBS Lua Scripting Basics

OBS loads Lua scripts from **Tools > Scripts**. The script lifecycle consists of:

- `script_description()` — returns a string shown in the Scripts dialog
- `script_properties()` — returns an `obs_properties_t` object for UI controls
- `script_update(settings)` — called when script settings change
- `script_defaults(settings)` — sets default values for settings
- `script_load(settings)` — called once when the script loads
- `script_unload()` — called once when the script unloads or OBS exits
- `script_tick(seconds)` — called every frame (use sparingly)

The OBS Lua module is accessed via:
```lua
local obs = obslua
```

## Key OBS Lua APIs

- `obs.obs_frontend_*` — frontend/UI interactions
- `obs.obs_scene_*` / `obs.obs_source_*` — scene and source manipulation
- `obs.obs_properties_*` — building settings UI
- `obs.obs_data_*` — reading/writing settings data
- `obs.timer_add(callback, ms)` / `obs.timer_remove(callback)` — timers
- `obs.signal_handler_*` — event signals

## File Structure

```
obs-interact-click/
├── CLAUDE.md
└── obs-interact-click.lua   # Main script file (loaded by OBS)
```

## Development Workflow

1. Edit the `.lua` script file
2. In OBS: **Tools > Scripts**, click the reload button (circular arrow) to hot-reload
3. Check **Help > Log Files > View Current Log** for Lua errors and `print()` output
4. Logs also appear in the OBS log viewer under **Help > Log Files**

Use `print()` for debugging — output appears in the OBS log.

## Common Patterns

### Timer-based actions
```lua
local function on_tick()
    -- do something periodically
end

function script_load(settings)
    obs.timer_add(on_tick, 1000) -- every 1000ms
end

function script_unload()
    obs.timer_remove(on_tick)
end
```

### Hotkey registration
```lua
local my_hotkey = obs.OBS_INVALID_HOTKEY_ID

function script_load(settings)
    my_hotkey = obs.obs_hotkey_register_frontend(
        "my_hotkey_id", "My Action", function(pressed)
            if pressed then
                -- do action
            end
        end
    )
    local hotkey_save = obs.obs_data_get_array(settings, "my_hotkey")
    obs.obs_hotkey_load(my_hotkey, hotkey_save)
    obs.obs_data_array_release(hotkey_save)
end

function script_save(settings)
    local hotkey_save = obs.obs_hotkey_save(my_hotkey)
    obs.obs_data_set_array(settings, "my_hotkey", hotkey_save)
    obs.obs_data_array_release(hotkey_save)
end
```

## Notes

- OBS uses Lua 5.1 — avoid Lua 5.2+ features (e.g., `goto`, `table.pack`)
- Always release OBS objects with the corresponding `_release()` call to avoid memory leaks
- The `obslua` global is always available inside OBS; no require needed
- Scripts run on the OBS main thread; avoid blocking calls
