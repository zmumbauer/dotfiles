local wezterm = require("wezterm")

local function is_light_appearance()
  if wezterm.gui == nil then
    return false
  end

  return not wezterm.gui.get_appearance():find("Dark")
end

local schemes = {
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

local base_palettes = {
  dark = {
    background = schemes["devbox-dark"].background,
    chrome = "#1b2129",
    surface = "#232a33",
    text = schemes["devbox-dark"].foreground,
    muted = "#8b94a7",
    accent = schemes["devbox-dark"].brights[5],
  },
  light = {
    background = schemes["devbox-light"].background,
    chrome = "#eef2f7",
    surface = "#e3e8f0",
    text = schemes["devbox-light"].foreground,
    muted = "#667085",
    accent = "#7a8cff",
  },
}

local function hex_to_rgb(hex)
  local value = hex:gsub("#", "")
  return tonumber(value:sub(1, 2), 16), tonumber(value:sub(3, 4), 16), tonumber(value:sub(5, 6), 16)
end

local function blend(base, overlay, ratio)
  local base_r, base_g, base_b = hex_to_rgb(base)
  local overlay_r, overlay_g, overlay_b = hex_to_rgb(overlay)

  local function channel(from, to)
    return math.floor((from * (1 - ratio)) + (to * ratio) + 0.5)
  end

  return string.format(
    "#%02x%02x%02x",
    channel(base_r, overlay_r),
    channel(base_g, overlay_g),
    channel(base_b, overlay_b)
  )
end

local function current_palette()
  return is_light_appearance() and base_palettes.light or base_palettes.dark
end

local function build_tab_bar_palette(palette)
  return {
    background = palette.chrome,
    inactive_fill = palette.surface,
    inactive_text = palette.muted,
    inactive_hover_fill = blend(palette.surface, palette.accent, 0.10),
    inactive_hover_text = palette.text,
    active_fill = blend(palette.surface, palette.accent, 0.22),
    active_text = palette.text,
    new_tab_fill = palette.chrome,
    new_tab_text = palette.muted,
    new_tab_hover_fill = blend(palette.chrome, palette.accent, 0.10),
    new_tab_hover_text = palette.text,
  }
end

local function trim(text)
  return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function extract_tmux_session_name(title)
  local session_name = trim((title or ""):match("^(.-)%s+·%s+%d+%s+.+$"))
  if session_name ~= "" then
    return session_name
  end
end

local function compact_title(tab_info)
  local title = trim(tab_info.tab_title)
  if title ~= "" then
    return title
  end

  title = trim(tab_info.active_pane.title)
  if title == "" then
    return string.format("tab %d", tab_info.tab_index + 1)
  end

  local tmux_session_name = extract_tmux_session_name(title)
  if tmux_session_name then
    return tmux_session_name
  end

  if title:find("[/\\]") and not title:find("%s") then
    title = title:gsub(".*[/\\]", "")
  end

  return title
end

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
  local palette = build_tab_bar_palette(current_palette())
  local fill = palette.inactive_fill
  local text = palette.inactive_text
  local chrome_width = 5

  if tab.is_active then
    fill = palette.active_fill
    text = palette.active_text
  elseif hover then
    fill = palette.inactive_hover_fill
    text = palette.inactive_hover_text
  end

  local title = wezterm.truncate_right(compact_title(tab), math.max(8, max_width - chrome_width))

  return wezterm.format({
    { Background = { Color = palette.background } },
    { Foreground = { Color = fill } },
    { Text = "" },
    { Background = { Color = fill } },
    { Foreground = { Color = text } },
    { Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
    { Text = " " .. title .. " " },
    { Attribute = { Intensity = "Normal" } },
    { Background = { Color = palette.background } },
    { Foreground = { Color = fill } },
    { Text = "" },
    { Background = { Color = palette.background } },
    { Text = " " },
  })
end)

local config = wezterm.config_builder()
local ui_palette = current_palette()
local tab_bar = build_tab_bar_palette(ui_palette)

config.color_schemes = schemes
config.colors = {
  tab_bar = {
    background = tab_bar.background,
    active_tab = {
      bg_color = tab_bar.background,
      fg_color = tab_bar.active_text,
    },
    inactive_tab = {
      bg_color = tab_bar.background,
      fg_color = tab_bar.inactive_text,
    },
    inactive_tab_hover = {
      bg_color = tab_bar.background,
      fg_color = tab_bar.inactive_hover_text,
    },
    new_tab = {
      bg_color = tab_bar.new_tab_fill,
      fg_color = tab_bar.new_tab_text,
    },
    new_tab_hover = {
      bg_color = tab_bar.new_tab_hover_fill,
      fg_color = tab_bar.new_tab_hover_text,
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
config.font_size = 14
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
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_tab_index_in_tab_bar = false
config.tab_max_width = 36
config.macos_window_background_blur = 20
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 75,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 75,
}

return config
