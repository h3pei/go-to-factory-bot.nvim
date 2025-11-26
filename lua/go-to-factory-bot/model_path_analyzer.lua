local M = {}

---開いているバッファがモデルファイルかどうかを判定
---@param file_path string|nil
---@return boolean
function M.is_model_file(file_path)
  file_path = file_path or vim.api.nvim_buf_get_name(0)

  -- app/models/ 配下のファイルかチェック
  if file_path:match("app/models/") and file_path:match("%.rb$") then
    return true
  end

  return false
end

---モデルファイルとして除外すべきパターンかどうかを判定
---@param file_path string
---@return boolean
function M.is_excluded_pattern(file_path)
  -- concerns ディレクトリ
  if file_path:match("/concerns/") then
    return true
  end

  -- application_record.rb
  if file_path:match("application_record%.rb$") then
    return true
  end

  return false
end

---@param file_path string|nil
---@return string|nil model_name
---@return string|nil namespace
---@return string|nil error_message
function M.extract_model_info(file_path)
  file_path = file_path or vim.api.nvim_buf_get_name(0)

  if not M.is_model_file(file_path) then
    return nil, nil, "Not a model file"
  end

  if M.is_excluded_pattern(file_path) then
    return nil, nil, "This file is not associated with a factory file"
  end

  -- app/models/ 以降のパスを抽出
  -- 例: app/models/admin/user.rb → admin/user.rb
  local relative_path = file_path:match("app/models/(.+)$")
  if not relative_path then
    return nil, nil, "Failed to extract relative path"
  end

  -- ファイル名を取得
  local model_name = relative_path:match("([^/]+)%.rb$")
  if not model_name then
    return nil, nil, "Failed to extract model name"
  end

  -- ネームスペースを抽出
  -- 例: admin/user.rb → admin/
  local namespace = relative_path:match("(.+)/[^/]+%.rb$")
  if namespace then
    namespace = namespace .. "/"
  end

  return model_name, namespace, nil
end

return M
