obs = obslua

local source_name = ""
local hotkey_id = obs.OBS_INVALID_HOTKEY_ID

-- ────────────────────────────────────────────────────────────
-- Core action
-- ────────────────────────────────────────────────────────────

local function interact()
    local source = obs.obs_get_source_by_name(source_name)
    if source == nil then
        print("[obs-interact-click] Source not found: " .. source_name)
        return
    end
    obs.obs_frontend_open_source_interaction(source)
    obs.obs_source_release(source)
end

-- ────────────────────────────────────────────────────────────
-- Script lifecycle
-- ────────────────────────────────────────────────────────────

function script_description()
    return "Opens the Interact window for a browser source.\n\nSelect a browser source and use the button or hotkey to open its interaction window."
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

    -- Manual trigger button
    obs.obs_properties_add_button(props, "interact_btn", "Interact Now",
        function() interact() end)

    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "source_name", "")
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
end

function script_load(settings)
    hotkey_id = obs.obs_hotkey_register_frontend(
        "obs_interact_click", "Interact: Open Browser Source",
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
