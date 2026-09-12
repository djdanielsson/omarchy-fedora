-- Input defaults: Omarchy base + ThinkPad T14s (Intel) deltas.
-- Omarchy part from omacom/omarchy quattro default/hypr/input.lua (MIT).
-- Fedora deltas: tap-to-click ON (Omarchy leaves it off), disable_while_typing
-- ON for the T14s deck, TrackPoint middle-scroll devices, Warp scroll speed.
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

local function read_vconsole()
  local values = {}
  local file = io.open("/etc/vconsole.conf", "r")
  if not file then
    return values
  end

  for line in file:lines() do
    local key, value = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
    if key and value then
      value = value:gsub("%s+#.*$", "")
      value = value:gsub('^"(.*)"$', "%1")
      value = value:gsub("^'(.*)'$", "%1")
      values[key] = value
    end
  end

  file:close()
  return values
end

-- Layouts that can't type Latin letters. Keep in sync with Omarchy upstream.
local non_latin_layouts =
  " af am ara bd bg by et ge gr il in iq ir kg kh kz la lk mk mm mn mv np rs ru sy th tj ua "

local vconsole = read_vconsole()

local kb_layout = vconsole.XKBLAYOUT or "us"
local kb_variant = vconsole.XKBVARIANT or ""
local kb_options = "compose:caps,shift:both_capslock_cancel"

-- Hyprland resolves keybindings against the first kb_layout entry, so a
-- leading non-Latin layout would break SUPER+W-style binds. Prepend us.
if non_latin_layouts:find(" " .. kb_layout:match("^[^,]*") .. " ", 1, true) then
  kb_layout = "us," .. kb_layout
  kb_variant = "," .. kb_variant
  kb_options = kb_options .. ",grp:alts_toggle"
end

hl.config({
  input = {
    kb_layout = kb_layout,
    kb_variant = kb_variant,
    kb_model = "",
    kb_options = kb_options,
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,

    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,

    touchpad = {
      natural_scroll = false,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
      -- Fedora/ThinkPad deltas (Omarchy default.conf had these off/absent):
      tap_to_click = true,
      disable_while_typing = true,
      drag_lock = false,
      middle_button_emulation = false,
    },
  },

  misc = {
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

-- ThinkPad TrackPoint middle-button scroll (button 274). Name varies by gen;
-- unknown device names are ignored, safe to keep all three.
-- Per-device syntax: hl.device(), NOT hl.config().device (see wiki Devices).
hl.device({
  name = "TPPS/2 IBM TrackPoint",
  sensitivity = 0,
  accel_profile = "adaptive",
  scroll_method = "on_button_down",
  scroll_button = 274,
})
hl.device({
  name = "ELAN TrackPoint",
  sensitivity = 0,
  accel_profile = "adaptive",
  scroll_method = "on_button_down",
  scroll_button = 274,
})
hl.device({
  name = "SynPS/2 Synaptics TouchPad",
  enabled = true,
})

-- Visible cursor (adwaita-cursor-theme is in packages-common.txt).
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_THEME", "Adwaita")

-- Per-terminal touchpad scroll speeds (Omarchy upstream values + Warp).
o.window("(Alacritty|kitty)", { scroll_touchpad = 1.5 })
o.window("foot", { scroll_touchpad = 2.0 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
o.window("warp-terminal|Warp", { scroll_touchpad = 1.0 })
