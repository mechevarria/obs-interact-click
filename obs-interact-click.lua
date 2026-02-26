obs = obslua

local source_name = ""
local click_x = 0
local click_y = 0
local hotkey_id = obs.OBS_INVALID_HOTKEY_ID

-- ────────────────────────────────────────────────────────────
-- Core actions
-- ────────────────────────────────────────────────────────────

local function send_click()
    local source = obs.obs_get_source_by_name(source_name)
    if source == nil then
        print("[obs-interact-click] Source not found: " .. source_name)
        return
    end
    local event = obs.obs_mouse_event()
    event.modifiers = 0
    event.x = click_x
    event.y = click_y
    obs.obs_source_send_mouse_click(source, event, 0, false, 1) -- press
    obs.obs_source_send_mouse_click(source, event, 0, true, 1)  -- release
    obs.obs_source_release(source)
    print(string.format("[obs-interact-click] Clicked (%d, %d) on '%s'", click_x, click_y, source_name))
end

local function on_click_timer()
    obs.timer_remove(on_click_timer)
    send_click()
end

local function interact()
    local source = obs.obs_get_source_by_name(source_name)
    if source == nil then
        print("[obs-interact-click] Source not found: " .. source_name)
        return
    end
    obs.obs_frontend_open_source_interaction(source)
    obs.obs_source_release(source)
    obs.timer_add(on_click_timer, 200)
end

-- ────────────────────────────────────────────────────────────
-- Script lifecycle
-- ────────────────────────────────────────────────────────────

function script_description()
    return "Opens the Interact window for a browser source, then sends a left mouse click at the specified coordinates.\n\nCoordinates are in the browser source's pixel space (e.g. 0–1920, 0–1080)."
end

function script_properties()
    local props = obs.obs_properties_create()

    -- Dropdown: only browser sources
    local list = obs.obs_properties_add_list(
        props, "source_name", "Browser Source",
        obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_STRING
    )
    obs.obs_property_list_add_string(list, "-- select --", "")

    local sources = obs.obs_enum_sources()
    if sources then
        for _, source in ipairs(sources) do
            if obs.obs_source_get_id(source) == "browser_source" then
                local name = obs.obs_source_get_name(source)
                obs.obs_property_list_add_string(list, name, name)
            end
        end
        obs.source_list_release(sources)
    end

    -- Click coordinates
    obs.obs_properties_add_int(props, "click_x", "Click X", 0, 7680, 1)
    obs.obs_properties_add_int(props, "click_y", "Click Y", 0, 4320, 1)

    -- Manual trigger button
    obs.obs_properties_add_button(props, "interact_btn", "Interact & Click",
        function() interact() end)

    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "source_name", "")
    obs.obs_data_set_default_int(settings, "click_x", 0)
    obs.obs_data_set_default_int(settings, "click_y", 0)
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
    click_x = obs.obs_data_get_int(settings, "click_x")
    click_y = obs.obs_data_get_int(settings, "click_y")
end

function script_load(settings)
    hotkey_id = obs.obs_hotkey_register_frontend(
        "obs_interact_click", "Interact: Open Browser Source & Click",
        function(pressed)
            if pressed then interact() end
        end
    )

    local saved = obs.obs_data_get_array(settings, "interact_hotkey")
    obs.obs_hotkey_load(hotkey_id, saved)
    obs.obs_data_array_release(saved)
end

function script_save(settings)
    local saved = obs.obs_hotkey_save(hotkey_id)
    obs.obs_data_set_array(settings, "interact_hotkey", saved)
    obs.obs_data_array_release(saved)
end

function script_unload()
    obs.timer_remove(on_click_timer)
end
