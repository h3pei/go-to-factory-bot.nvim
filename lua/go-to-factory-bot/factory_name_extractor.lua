local M = {}

-- Supported factory_bot methods
local FACTORY_BOT_METHODS = {
  "create",
  "build",
  "build_stubbed",
  "attributes_for",
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

  return pcall(vim.treesitter.get_parser, 0, "ruby")
end

---メソッド名がFactoryBotメソッドかチェック
---@param method_name string
---@return boolean
local function is_factory_bot_method(method_name)
  return vim.list_contains(FACTORY_BOT_METHODS, method_name)
end

---call_node からメソッド名を取得
---@param call_node TSNode
---@return string|nil
local function get_method_name(call_node)
  for child in call_node:iter_children() do
    local child_type = child:type()
    if child_type == "identifier" or child_type == "method" then
      return vim.treesitter.get_node_text(child, 0)
    end
  end

  return nil
end

---親ノードを遡って FactoryBot メソッド呼び出しを探す
---FactoryBotメソッドの呼び出しが見つかるまで探索を続ける
---@param node TSNode
---@return TSNode|nil
local function find_factory_bot_call_by_ancestors(node)
  local current = node

  -- 最大10階層まで親を遡る
  for _ = 1, 10 do
    if not current then
      break
    end

    local node_type = current:type()
    if node_type == "call" or node_type == "method_call" then
      local method_name = get_method_name(current)
      if method_name and is_factory_bot_method(method_name) then
        return current
      end
    end

    current = current:parent()
  end

  return nil
end

---指定された行から FactoryBot メソッド呼び出しを探す（再帰探索）
---@param node TSNode
---@param row number
---@return TSNode|nil
local function find_factory_bot_call_in_row(node, row)
  if not node then
    return nil
  end

  local node_type = node:type()

  -- このノードがメソッド呼び出しかチェック
  if node_type == "call" or node_type == "method_call" then
    -- ノードが対象行と重なっているかチェック
    local start_row, _, end_row, _ = node:range()
    if start_row <= row and row <= end_row then
      -- メソッド名を取得してFactoryBotメソッドかチェック
      local method_name = get_method_name(node)
      if method_name and is_factory_bot_method(method_name) then
        return node
      end
    end
  end

  -- 子ノードを再帰的に探索
  for child in node:iter_children() do
    local result = find_factory_bot_call_in_row(child, row)
    if result then
      return result
    end
  end

  return nil
end

---第1引数から factory_bot のシンボルを取得
---@param call_node TSNode
---@return string|nil
local function get_first_symbol_argument(call_node)
  for child in call_node:iter_children() do
    if child:type() == "argument_list" then
      -- 第1引数のみ
      local first_arg = child:named_child(0)
      if first_arg and first_arg:type() == "simple_symbol" then
        local text = vim.treesitter.get_node_text(first_arg, 0)
        return text:gsub("^:", "") -- ":" を除去
      end

      return nil
    end
  end
end

---カーソル位置からファクトリ名を抽出
---@return string|nil factory_name
---@return string|nil error_message
function M.extract()
  -- カーソル位置を取得
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1 -- 0-based
  local cursor_col = cursor[2]

  -- パーサーとルートノードを取得
  local parser = vim.treesitter.get_parser(0, "ruby")
  local tree = parser:parse()[1]
  local root = tree:root()

  -- カーソル位置のノードを取得
  local node = root:named_descendant_for_range(cursor_row, cursor_col, cursor_row, cursor_col)

  local call_node = nil

  -- アプローチ1: 現在行から factory_bot のメソッドを検索
  call_node = find_factory_bot_call_in_row(root, cursor_row)

  -- アプローチ2: 見つからなければカーソル位置のノードから親を辿る (複数行にまたがるメソッド呼び出し対応)
  if not call_node and node then
    call_node = find_factory_bot_call_by_ancestors(node)
  end

  if not call_node then
    return nil, "No FactoryBot method call found"
  end

  -- ファクトリ名を抽出
  local factory_name = get_first_symbol_argument(call_node)
  if not factory_name then
    return nil, "Could not extract factory name from arguments"
  end

  return factory_name, nil
end

return M
