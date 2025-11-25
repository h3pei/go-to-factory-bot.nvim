local TreesitterExtractor = require("go-to-factory-bot.treesitter_extractor")

local M = {}

---@param line string
---@return string|nil factory_name
---@return string|nil error_message
function M.extract(line)
  -- 後方互換のためにlineパラメータは受け取るが使用しない
  -- Treesitterはカーソル位置から直接抽出する
  return TreesitterExtractor.extract()
end

return M
