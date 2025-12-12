local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
local font = wezterm.font({
	family = "ZedMono Nerd Font",
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
})

config.check_for_updates = false

-- config.color_scheme = "rose-pine"
config.color_scheme = "Moonfly (Gogh)"
-- config.color_scheme = "Rydgel (terminal.sexy)"
-- config.color_scheme = "VisiBone (terminal.sexy)"
-- config.color_scheme = "Derp (terminal.sexy)"
-- config.color_scheme = "Bitmute (terminal.sexy)"

config.inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 }

-- Configure window.
config.window_decorations = "NONE"
config.window_padding = { left = 2, right = 1, top = 1, bottom = 1 }
config.window_background_opacity = 0.75
config.text_background_opacity = 1.0
config.adjust_window_size_when_changing_font_size = false
config.animation_fps = 1

-- Configure tab bar.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_and_split_indices_are_zero_based = true

-- Configure text.
config.font = font
config.font_size = 15
config.unicode_version = 14

-- Configure cursor.
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.hide_mouse_cursor_when_typing = false

-- Configure scrollback.
config.scrollback_lines = 65536
config.enable_scroll_bar = false

-- Configure command palette.
config.command_palette_rows = nil
config.command_palette_font = font
config.command_palette_font_size = 15

-- Configure stateless close-able processes.
config.skip_close_confirmation_for_processes_named = {
	"bash",
	"sh",
	"btop",
	"clac",
	"qalc",
	"dust",
	"pulsemixer",
	"wev",
	"deno",
}

-- Configure keys.
config.disable_default_key_bindings = true
config.key_tables = {}
config.keys = {
	{ key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
	{ key = "j", mods = "CTRL|SHIFT", action = act.ScrollToPrompt(1) },
	{ key = "k", mods = "CTRL|SHIFT", action = act.ScrollToPrompt(-1) },
	{ key = "a", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
	{ key = "s", mods = "CTRL|SHIFT", action = act.QuickSelect },
	{ key = "d", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
	{ key = "f", mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },
	{ key = "Escape", mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	{ key = "Tab", mods = "ALT", action = act.PaneSelect },
	{ key = "q", mods = "ALT", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "w", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "1", mods = "ALT", action = act.ActivateTab(0) },
	{ key = "2", mods = "ALT", action = act.ActivateTab(1) },
	{ key = "3", mods = "ALT", action = act.ActivateTab(2) },
	{ key = "4", mods = "ALT", action = act.ActivateTab(3) },
	{ key = "5", mods = "ALT", action = act.ActivateTab(4) },
	{ key = "6", mods = "ALT", action = act.ActivateTab(5) },
	{ key = "7", mods = "ALT", action = act.ActivateTab(6) },
	{ key = "8", mods = "ALT", action = act.ActivateTab(7) },
	{ key = "9", mods = "ALT", action = act.ActivateTab(8) },
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "h", mods = "ALT|CTRL", action = act.SplitPane({ direction = "Left" }) },
	{ key = "j", mods = "ALT|CTRL", action = act.SplitPane({ direction = "Down" }) },
	{ key = "k", mods = "ALT|CTRL", action = act.SplitPane({ direction = "Up" }) },
	{ key = "l", mods = "ALT|CTRL", action = act.SplitPane({ direction = "Right" }) },
	{ key = "h", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ key = "j", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },
	{ key = "k", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "l", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 1 }) },
}

-- Configure search mode.
config.key_tables.search_mode = {
	{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
	{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
	{ key = "f", mods = "CTRL|SHIFT", action = act.CopyMode("CycleMatchType") },
	{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
	{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
}

-- Configure copy mode.
config.key_tables.copy_mode = {
	{
		key = "v",
		mods = "NONE",
		action = act.CopyMode({ SetSelectionMode = "Cell" }),
	},
	{
		key = "x",
		mods = "NONE",
		action = act.CopyMode({ SetSelectionMode = "Line" }),
	},
	{ key = "Escape", mods = "NONE", action = act.Multiple({
		act.ScrollToBottom,
		act.CopyMode("Close"),
	}) },
	{ key = "c", mods = "CTRL", action = act.Multiple({
		act.ScrollToBottom,
		act.CopyMode("Close"),
	}) },
	{
		key = "y",
		mods = "NONE",
		action = act.Multiple({
			act.CopyTo("ClipboardAndPrimarySelection"),
			act.ScrollToBottom,
			act.CopyMode("Close"),
		}),
	},
	{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
	{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
	{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
	{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
	{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
	{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
	{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
	{ key = "T", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
	{ key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
	{ key = "h", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
	{ key = "l", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
	{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
	{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
	{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
	{ key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
}

-- Configure quick select mode.
config.quick_select_remove_styling = true

-- Select entire output.
config.mouse_bindings = {
	{
		event = { Down = { streak = 4, button = "Left" } },
		mods = "NONE",
		action = act.SelectTextAtMouseCursor("SemanticZone"),
	},
}

return config
