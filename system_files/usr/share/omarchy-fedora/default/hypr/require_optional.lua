-- Require a module only when it can be found on package.path.
-- From Omarchy (MIT, omacom/omarchy quattro: default/hypr/require_optional.lua), verbatim.
-- Errors inside existing modules still surface normally.

local M = {}

function M.module(module)
  if package.searchpath(module, package.path) then
    return require(module)
  end
end

return M
