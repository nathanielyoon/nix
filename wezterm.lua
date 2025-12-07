local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
config.key_tables = {}

-- Configure window.
config.window_padding = {
	left = 1,
	right = 1,
	top = 1,
	bottom = 1,
}
config.window_background_opacity = 0.75
config.text_background_opacity = 1.0

-- Configure tab bar.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- Configure font.
config.font = wezterm.font({
	family = "ZedMono Nerd Font",
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
})
config.font_size = 15

-- Show cursor when typing.
config.hide_mouse_cursor_when_typing = false

-- Configure scrollback.
config.scrollback_lines = 65536
config.enable_scroll_bar = false

-- Configure search mode.
config.key_tables.search_mode = {
	{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
	{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
	{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
	{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
}

-- Configure other key assignments.
config.disable_default_key_bindings = true
config.keys = {
	{ key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
}

return config
