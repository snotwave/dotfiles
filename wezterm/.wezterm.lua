local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = 'Ocean Dark (Gogh)'
config.window_background_opacity = 0.9
config.text_background_opacity = 0.75

config.hide_tab_bar_if_only_one_tab = true

config.font = wezterm.font_with_fallback{
	'FiraCode',
	'NotoSansCJK'
}

return config
