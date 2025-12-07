local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Minimize window padding.
config.window_padding = {
	left = 1,
	right = 1,
	top = 1,
	bottom = 1,
}

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

return config
