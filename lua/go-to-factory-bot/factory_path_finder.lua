local Inflector = require("go-to-factory-bot.inflector")

local M = {}

local DEFAULT_DEFINITION_PATHS = {
  "spec/factories",
  "test/factories",
  "factories",
}

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
---@return string|nil
function M.find_by_name(factory_name)
  local patterns = generate_search_patterns(factory_name)

  -- 複数のディレクトリを順に探索
  for _, dir_path in ipairs(DEFAULT_DEFINITION_PATHS) do
    for _, pattern in ipairs(patterns) do
      local paths = vim.fs.find(pattern, { path = dir_path, type = "file", limit = 1 })
      if not vim.tbl_isempty(paths) then
        return paths[1]
      end
    end
  end

  return nil
end

---@param factory_name string
---@param subdirectory string|nil (e.g., "admin/")
---@return string|nil
function M.find_by_name_with_namespace(factory_name, subdirectory)
  local patterns = generate_search_patterns(factory_name)

  -- 名前空間付きのパスを優先的に探索
  if subdirectory then
    for _, dir_path in ipairs(DEFAULT_DEFINITION_PATHS) do
      for _, pattern in ipairs(patterns) do
        -- 完全なパスを構築: "spec/factories/admin/users.rb"
        local full_path = dir_path .. "/" .. subdirectory .. pattern
        -- ファイルの存在確認
        if vim.fn.filereadable(full_path) == 1 then
          return full_path
        end
      end
    end
  end

  -- フォールバック: 既存のfind_by_name()を使用
  return M.find_by_name(factory_name)
end

return M
