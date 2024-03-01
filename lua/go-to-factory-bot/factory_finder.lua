local Inflector = require("go-to-factory-bot.inflector")

local M = {}

---@param model_name string
---@param factory_path string
---@param suffix string
---@return string|nil
function M.find_by_model(model_name, factory_path, suffix)
  local plural_name = Inflector.pluralize(model_name)
  local factory_file_name = plural_name .. suffix .. ".rb"
  local paths = vim.fs.find(factory_file_name, { path = factory_path, type = "file", limit = 1 })

  if not vim.tbl_isempty(paths) then
    return paths[1]
  end
end

return M
