local wezterm = require('wezterm')
local config = wezterm.config_builder()
local io = require("io")
local fonts = require("user.fonts")
local font = fonts.dina_remaster
-- local font = fonts.ark_pixel10

-- FONTS
-- config.font = wezterm.font(font.regular)
local confdir = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
local f = io.open(confdir .. "/env_theme_name", "r")
local theme_name = "gruvbox"
if f ~= nil then
    theme_name = f:read("*l")
    f:close()
    wezterm.add_to_config_reload_watch_list(confdir .. "/env_theme_name")
end

---@diagnostic disable-next-line: inject-fieldかみさまちつ
config.font = wezterm.font_with_fallback({
    -- fonts.unifontex.regular,
    font.regular,
    fonts.ark_pixel12.regular,
    fonts.cozette.regular,
    { family = "Noto Sans Mono CJK JP", scale = 0.95 },
    { family = "Noto Sans CJK JP", scale = 0.95 }
})
font.rules[1].font = wezterm.font_with_fallback({
    {family = 'DinaRemaster', weight = 'Bold', style = 'Normal', italic = false},
    fonts.ark_pixel12.regular,
    fonts.cozette.regular,
})
font.rules[2].font = wezterm.font_with_fallback({
    {family = 'DinaRemaster', weight = 'Regular', style = 'Normal', italic = false},
    fonts.ark_pixel12.regular,
    fonts.cozette.regular,
})
font.rules[3].font = wezterm.font_with_fallback({
    {family = 'DinaRemaster', weight = 'Bold', style = 'Normal', italic = false},
    fonts.ark_pixel12.regular,
    fonts.cozette.regular,
})
-- かたかなめろこへをそのちのさだめぞおぞお
config.font_rules = font.rules
config.font_size = font.size
config.bold_brightens_ansi_colors = font.brighten
config.use_cap_height_to_scale_fallback_fonts = true
-- config.cell_width = 0.55
-- config.line_height = 0.9
config.cell_width = font.cell_width
config.line_height = font.line_height
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- COLOR THEME
local theme = require("user.theme").init(theme_name)
-- local theme = require("user.theme").init("GruvboxDark")
config.color_scheme = theme.color_scheme()
config.colors = theme.colors()
-- config.color_scheme = 'Laser'
-- config.color_scheme_dirs = { "~/.config/wezterm/colors" }

-- CURSOR AND TEXT BLINK
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'
config.cursor_blink_rate = 600
config.cursor_thickness = 0.7
config.text_blink_ease_in = 'Constant'
config.text_blink_ease_out = 'Constant'
config.text_blink_rapid_ease_in = 'Constant'
config.text_blink_rapid_ease_out = 'Constant'

-- WINDOW
config.exit_behavior = 'Close'
config.window_close_confirmation = 'NeverPrompt'
---@diagnostic disable-next-line: inject-field
config.exit_behavior_messaging = 'None'
---@diagnostic disable-next-line: inject-field
config.prefer_to_spawn_tabs = false
config.enable_scroll_bar = false
config.pane_focus_follows_mouse = true
config.warn_about_missing_glyphs = false
config.window_background_opacity = 0.95
-- config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = require("utils.osspec")("RESIZE", "TITLE | RESIZE", "TITLE | RESIZE")
config.window_padding = {
    left = 1,
    right = 1,
    top = 1,
    bottom = 1,
}
-- config.window_padding = {
--     left = 1,
--     right = 1,
--     top = 6,
--     bottom = 6,
-- }

-- META
config.term = "xterm-256color"
config.tiling_desktop_environments = {
    'X11 LG3D',
    'X11 bspwm',
    'X11 i3',
    'X11 dwm',
    'X11 awesome',
    'X11 Qtile',
} -- FIXME: remove in next version

-- MAPPINGS
config.enable_kitty_keyboard = false
-- config.swap_backspace_and_delete = true
config.hide_mouse_cursor_when_typing = false
config.key_map_preference = "Mapped"
config.scroll_to_bottom_on_input = true
config.disable_default_key_bindings = true
-- config.disable_default_mouse_bindings = true
config.disable_default_quick_select_patterns = true

---@diagnostic disable-next-line: inject-field
-- config.leader = { key = '', mods = 'CTRL|SHIFT|ALT' }
local user_mappings = require("user.mappings")
config.keys = user_mappings.keys

config.mouse_bindings = user_mappings.mouse

return config
