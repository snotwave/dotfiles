local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = 'hybrid (terminal.sexy)'
config.window_background_opacity = 0.99
config.text_background_opacity = 0.99

config.hide_tab_bar_if_only_one_tab = true

config.font = wezterm.font_with_fallback{
	'Monaspace Krypton',
	'NotoSansCJK'
}

return config
