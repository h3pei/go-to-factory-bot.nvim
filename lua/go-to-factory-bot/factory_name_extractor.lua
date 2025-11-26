local M = {}

-- 対応するfactory_botメソッド（拡張可能）
local FACTORY_BOT_METHODS = {
  "create",
  "build",
  "build_stubbed",
  "attributes_for",
  -- 将来的に追加する場合はここに追加するだけ
  -- "create_list",
  -- "build_list",
  -- "create_pair",
  -- "build_pair",
}

---Treesitterが利用可能かチェック
---@return boolean
function M.is_available()
  local ok, _ = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return false
  end

  local parser_ok = pcall(vim.treesitter.get_parser, 0, "ruby")
  return parser_ok
end

---カーソル位置のノードを取得
---@return TSNode|nil
local function get_node_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1 -- 0-based
  local col = cursor[2]

  local parser = vim.treesitter.get_parser(0, "ruby")
  local tree = parser:parse()[1]
  local root = tree:root()

  return root:named_descendant_for_range(row, col, row, col)
end

---メソッド名を取得
---@param call_node TSNode
---@return string|nil
local function get_method_name(call_node)
  for child in call_node:iter_children() do
    local child_type = child:type()
    if child_type == "identifier" or child_type == "method" then
      local name = vim.treesitter.get_node_text(child, 0)
      return name
    end
  end
  return nil
end

---メソッド名がFactoryBotメソッドかチェック
---@param method_name string
---@return boolean
local function is_factory_bot_method(method_name)
  for _, name in ipairs(FACTORY_BOT_METHODS) do
    if name == method_name then
      return true
    end
  end
  return false
end

---ノードからメソッド呼び出しを探す（親ノードを遡る）
---FactoryBotメソッドの呼び出しが見つかるまで探索を続ける
---@param node TSNode
---@return TSNode|nil
local function find_method_call(node)
  local current = node

  -- 最大10階層まで親を遡る
  for _ = 1, 10 do
    if not current then
      break
    end

    local node_type = current:type()
    if node_type == "call" or node_type == "method_call" then
      -- メソッド名を取得してFactoryBotメソッドかチェック
      local method_name = get_method_name(current)
      if method_name and is_factory_bot_method(method_name) then
        return current
      end
      -- FactoryBotメソッドでない場合は、さらに親を探索
    end

    current = current:parent()
  end

  return nil
end

---指定行に重なる最初のFactoryBotメソッド呼び出しを探す（再帰探索）
---@param node TSNode
---@param target_row number
---@return TSNode|nil
local function find_first_factory_bot_call(node, target_row)
  if not node then
    return nil
  end

  local node_type = node:type()

  -- このノードがメソッド呼び出しかチェック
  if node_type == "call" or node_type == "method_call" then
    -- ノードが対象行と重なっているかチェック
    local start_row, _, end_row, _ = node:range()
    if start_row <= target_row and target_row <= end_row then
      -- メソッド名を取得してFactoryBotメソッドかチェック
      local method_name = get_method_name(node)
      if method_name and is_factory_bot_method(method_name) then
        return node
      end
    end
  end

  -- 子ノードを再帰的に探索
  for child in node:iter_children() do
    local result = find_first_factory_bot_call(child, target_row)
    if result then
      return result
    end
  end

  return nil
end

---引数リストから最初のシンボルを取得
---@param call_node TSNode
---@return string|nil
local function get_first_symbol_argument(call_node)
  for child in call_node:iter_children() do
    if child:type() == "argument_list" then
      for arg in child:iter_children() do
        -- :user のようなシンプルなシンボル
        if arg:type() == "simple_symbol" or arg:type() == "symbol" then
          local text = vim.treesitter.get_node_text(arg, 0)
          -- ":" を除去し、ハイフンをアンダースコアに変換
          return text:gsub("^:", ""):gsub("%-", "_")
        end

        -- :"user-profile" のようなクォート付きシンボル
        -- Rubyのシンボルは string ノードを子に持つことがある
        if arg:type() == "hash_key_symbol" or arg:type() == "symbol_literal" or arg:type() == "delimited_symbol" then
          local text = vim.treesitter.get_node_text(arg, 0)
          -- クォートと ":" を除去し、ハイフンをアンダースコアに変換
          return text:gsub("^[:\"']+", ""):gsub("[\"']$", ""):gsub("%-", "_")
        end
      end
    end
  end
  return nil
end

---カーソル位置からファクトリ名を抽出
---@return string|nil factory_name
---@return string|nil error_message
function M.extract()
  -- カーソル位置を取得
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1  -- 0-based
  local cursor_col = cursor[2]

  -- パーサーとルートノードを取得
  local parser = vim.treesitter.get_parser(0, "ruby")
  local tree = parser:parse()[1]
  local root = tree:root()

  -- カーソル位置のノードを取得
  local node = root:named_descendant_for_range(cursor_row, cursor_col, cursor_row, cursor_col)

  local call_node = nil

  -- アプローチ1: まず行全体から最初のメソッドを検索
  -- これにより、カーソルがどこにあっても行の最初のメソッドを優先的に検出
  call_node = find_first_factory_bot_call(root, cursor_row)

  -- アプローチ2: 見つからなければカーソル位置のノードから親を辿る
  -- これにより、複数行メソッド呼び出しの内部にカーソルがある場合も検出できる
  if not call_node and node then
    call_node = find_method_call(node)
  end

  if not call_node then
    return nil, "No FactoryBot method call found"
  end

  -- 既存のロジックを使ってファクトリ名を抽出
  local factory_name = get_first_symbol_argument(call_node)
  if not factory_name then
    return nil, "Could not extract factory name from arguments"
  end

  return factory_name, nil
end

return M
