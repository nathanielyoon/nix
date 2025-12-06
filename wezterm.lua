local wezterm = require "wezterm"
local config = wezterm.config_builder()

config.font = wezterm.font {
  family = "ZedMono Nerd Font",
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
}

return config
