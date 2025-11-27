local Inflector = require("go-to-factory-bot.inflector")

local M = {}

local DEFAULT_DEFINITION_PATHS = {
  "spec/factories",
  "test/factories",
  "factories",
}

---@param factory_name string
---@return table
local function get_file_name_patterns(factory_name)
  local singular = factory_name
  local plural = Inflector.pluralize(factory_name)

  return {
    plural .. ".rb", -- users.rb
    singular .. ".rb", -- user.rb
    plural .. "_factory.rb", -- users_factory.rb
    singular .. "_factory.rb", -- user_factory.rb
  }
end

---@param factory_name string
---@param subdirectory string|nil (e.g., "admin/")
---@return string|nil
function M.find_by_name(factory_name, subdirectory)
  local patterns = get_file_name_patterns(factory_name)

  for _, dir_path in ipairs(DEFAULT_DEFINITION_PATHS) do
    for _, pattern in ipairs(patterns) do
      local path = dir_path
      if subdirectory then
        -- 末尾の "/" を削除
        local subdir = subdirectory:gsub("/$", "")
        path = dir_path .. "/" .. subdir
      end

      local paths = vim.fs.find(pattern, { path = path, type = "file", limit = 1 })
      if not vim.tbl_isempty(paths) then
        return paths[1]
      end
    end
  end

  return nil
end

return M
