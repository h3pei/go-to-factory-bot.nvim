local TreesitterExtractor = require("go-to-factory-bot.treesitter_extractor")

local M = {}

---@param line string
---@return string|nil
function M.extract(line)
  -- 後方互換のためにlineパラメータは受け取るが使用しない
  -- Treesitterはカーソル位置から直接抽出する
  local factory_name, _ = TreesitterExtractor.extract()
  return factory_name
end

return M
