-- Personal input overrides. Loaded after Omarchy-Fedora defaults
-- (which already enable tap-to-click, disable-while-typing, TrackPoint
-- middle-scroll for the T14s). Uncomment and edit what you need.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

-- hl.config({
--   input = {
--     sensitivity = 0.35,
--     accel_profile = "flat",
--     touchpad = {
--       natural_scroll = true,
--       scroll_factor = 0.4,
--     },
--   },
-- })

-- Touchpad scroll direction (2026-09-12: natural/inverted per owner).
hl.config({
  input = {
    touchpad = {
      natural_scroll = true,
    },
  },
})

-- App-specific touchpad scroll speeds.
-- o.window("warp-terminal|Warp", { scroll_touchpad = 1.0 })
