local wezterm = require("wezterm")

local config = wezterm.config_builder()

local function is_light_appearance()
  if wezterm.gui == nil then
    return false
  end

  return not wezterm.gui.get_appearance():find("Dark")
end

config.color_schemes = {
  ["devbox-dark"] = {
    foreground = "#dcdcdc",
    background = "#15191f",
    cursor_bg = "#ffffff",
    cursor_fg = "#000000",
    cursor_border = "#ffffff",
    selection_bg = "#b3d7ff",
    selection_fg = "#000000",
    ansi = {
      "#14191e",
      "#b43c2a",
      "#00c200",
      "#c7c400",
      "#2744c7",
      "#c040be",
      "#00c5c7",
      "#c7c7c7",
    },
    brights = {
      "#686868",
      "#dd7975",
      "#58e790",
      "#ece100",
      "#a7abf2",
      "#e17ee1",
      "#60fdff",
      "#ffffff",
    },
  },
  ["devbox-light"] = {
    foreground = "#000000",
    background = "#ffffff",
    cursor_bg = "#000000",
    cursor_fg = "#ffffff",
    cursor_border = "#000000",
    selection_bg = "#b5d5ff",
    selection_fg = "#000000",
    ansi = {
      "#000000",
      "#bb0000",
      "#00bb00",
      "#bbbb00",
      "#0000bb",
      "#bb00bb",
      "#00bbbb",
      "#bbbbbb",
    },
    brights = {
      "#555555",
      "#ff5555",
      "#55ff55",
      "#ffff55",
      "#5555ff",
      "#ff55ff",
      "#55ffff",
      "#ffffff",
    },
  },
}

config.color_scheme = is_light_appearance() and "devbox-light" or "devbox-dark"
config.term = "xterm-256color"
config.font = wezterm.font_with_fallback({
  {
    family = "RobotoMono Nerd Font Mono",
    weight = "Medium",
  },
  "Monaco",
})
config.font_size = 12
config.line_height = .85
config.use_ime = true
config.bold_brightens_ansi_colors = true
config.initial_cols = 80
config.initial_rows = 25
config.use_resize_increments = true
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.default_cursor_style = "SteadyUnderline"
config.scrollback_lines = 1000000
config.enable_scroll_bar = false
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = .9
config.text_background_opacity = 1.0
config.enable_tab_bar = false
config.macos_window_background_blur = 20
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 75,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 75,
}

return config
