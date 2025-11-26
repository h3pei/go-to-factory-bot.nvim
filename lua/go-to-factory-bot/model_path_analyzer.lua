local M = {}

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

  -- *_base.rb
  if file_path:match("_base%.rb$") then
    return true
  end

  return false
end

---@param file_path string|nil
---@return string|nil model_name
---@return string|nil subdirectory
---@return string|nil error_message
function M.extract_model_info(file_path)
  file_path = file_path or vim.api.nvim_buf_get_name(0)

  -- モデルファイルかチェック
  if not M.is_model_file(file_path) then
    return nil, nil, "Not a model file"
  end

  -- 除外パターンチェック
  if M.is_excluded_pattern(file_path) then
    if file_path:match("/concerns/") then
      return nil, nil, "Concerns are not associated with factory files"
    else
      return nil, nil, "Base classes are not associated with factory files"
    end
  end

  -- app/models/ 以降のパスを抽出
  -- 例: app/models/admin/user.rb → admin/user.rb
  local relative_path = file_path:match("app/models/(.+)$")
  if not relative_path then
    return nil, nil, "Failed to extract relative path"
  end

  -- ファイル名（.rb を除く）を取得
  local model_name = relative_path:match("([^/]+)%.rb$")
  if not model_name then
    return nil, nil, "Failed to extract model name"
  end

  -- サブディレクトリを抽出（存在する場合）
  -- 例: admin/user.rb → admin/
  local subdirectory = relative_path:match("(.+)/[^/]+%.rb$")
  if subdirectory then
    subdirectory = subdirectory .. "/"
  end

  return model_name, subdirectory, nil
end

return M
