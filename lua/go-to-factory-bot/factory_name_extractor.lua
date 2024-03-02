local M = {}

local factory_bot_methods = {
  "create",
  "build",
  "build_stubbed",
  "attributes_for",
}

---@param line string
---@return string|nil
function M.extract(line)
  if line == "" then
    return
  end

  local factory_name = nil

  for _, factory_bot_method in pairs(factory_bot_methods) do
    factory_name = string.match(line, [[^.*]] .. factory_bot_method .. [[%(:([%w_]+).*%).*$]])
    if factory_name then
      break
    end
  end

  return factory_name
end

return M
