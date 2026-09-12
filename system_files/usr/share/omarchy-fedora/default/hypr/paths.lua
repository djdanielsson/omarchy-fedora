-- Shared path constants for Omarchy-Fedora's Hyprland Lua modules.
-- Ported from Omarchy (MIT, omacom/omarchy quattro: default/hypr/paths.lua).
-- Fedora delta: omarchy_path defaults to /usr/share/omarchy-fedora.

local home = os.getenv("HOME")

-- A variable that is set but empty means "unset" (XDG Base Directory spec);
-- bash's ${VAR:-fallback} in the sibling tools treats it the same way.
local function env_or(name, fallback)
  local value = os.getenv(name)
  if value == nil or value == "" then
    return fallback
  end
  return value
end

return {
  home = home,
  config_home = env_or("XDG_CONFIG_HOME", home .. "/.config"),
  state_home = env_or("XDG_STATE_HOME", home .. "/.local/state"),
  omarchy_path = env_or("OMARCHY_PATH", "/usr/share/omarchy-fedora"),
}
