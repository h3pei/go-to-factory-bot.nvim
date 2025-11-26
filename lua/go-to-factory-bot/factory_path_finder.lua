local Inflector = require("go-to-factory-bot.inflector")

local M = {}

---@param factory_name string
---@return table
local function generate_search_patterns(factory_name)
  local plural = Inflector.pluralize(factory_name)
  local singular = factory_name

  -- すべての一般的なパターンを生成
  local patterns = {
    plural .. ".rb", -- 1. users.rb (最も一般的)
    singular .. ".rb", -- 2. user.rb
    plural .. "_factory.rb", -- 3. users_factory.rb
    singular .. "_factory.rb", -- 4. user_factory.rb
  }

  -- 重複排除（plural と singular が同じ場合）
  local seen = {}
  local unique_patterns = {}
  for _, pattern in ipairs(patterns) do
    if not seen[pattern] then
      seen[pattern] = true
      table.insert(unique_patterns, pattern)
    end
  end

  return unique_patterns
end

---@param factory_name string
---@param definition_file_path string
---@return string|nil
function M.find_by_name(factory_name, definition_file_path)
  local patterns = generate_search_patterns(factory_name)

  for _, pattern in ipairs(patterns) do
    local paths = vim.fs.find(pattern, { path = definition_file_path, type = "file", limit = 1 })
    if not vim.tbl_isempty(paths) then
      return paths[1]
    end
  end

  return nil
end

return M
