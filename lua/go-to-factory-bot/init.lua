local Config = require("go-to-factory-bot.config")
local FactoryNameExtractor = require("go-to-factory-bot.factory_name_extractor")
local FactoryPathFinder = require("go-to-factory-bot.factory_path_finder")
local ModelPathAnalyzer = require("go-to-factory-bot.model_path_analyzer")
local Inflector = require("go-to-factory-bot.inflector")

local M = {}

local function notify(message, level)
  if not Config.silent then
    vim.notify(message, level)
  end
end

---@return "test_file"|"model_file"|"unknown"
local function detect_context()
  -- 1. モデルファイルかチェック
  if ModelPathAnalyzer.is_model_file() then
    return "model_file"
  end

  -- 2. FactoryBotメソッド呼び出しが存在するかチェック
  if FactoryNameExtractor.is_available() then
    local factory_name = FactoryNameExtractor.extract()
    if factory_name then
      return "test_file"
    end
  end

  return "unknown"
end

local function jump_from_factory_call()
  -- Treesitter の依存関係チェック
  if not FactoryNameExtractor.is_available() then
    notify(
      "Treesitter is not available. Please install nvim-treesitter and Ruby parser (:TSInstall ruby)",
      vim.log.levels.ERROR
    )
    return
  end

  -- FactoryNameExtractorを経由してファクトリ名を抽出
  local factory_name, error_message = FactoryNameExtractor.extract()

  if not factory_name then
    notify(string.format("Could not extract factory name: %s", error_message or "unknown error"), vim.log.levels.WARN)
    return
  end

  local factory_path = FactoryPathFinder.find_by_name(factory_name)

  if not factory_path then
    notify(string.format("Factory file not found for: %s", factory_name), vim.log.levels.WARN)
    return
  end

  vim.api.nvim_command(Config.jump_command .. " " .. factory_path)
end

local function jump_from_model_file()
  local model_name, subdirectory, error_message = ModelPathAnalyzer.extract_model_info()

  if not model_name then
    notify(error_message or "Failed to extract model information", vim.log.levels.WARN)
    return
  end

  -- モデル名から複数形に変換してファクトリ名を生成
  local factory_name = Inflector.pluralize(model_name)

  -- 名前空間を考慮して検索
  local factory_path = FactoryPathFinder.find_by_name_with_namespace(factory_name, subdirectory)

  if not factory_path then
    notify(string.format("Factory file not found for model: %s", model_name), vim.log.levels.WARN)
    return
  end

  vim.api.nvim_command(Config.jump_command .. " " .. factory_path)
end

local function go_to_factory_bot()
  local context = detect_context()

  if context == "test_file" then
    jump_from_factory_call()
  elseif context == "model_file" then
    jump_from_model_file()
  else
    notify("Not a model file or test file with FactoryBot method call", vim.log.levels.WARN)
  end
end

function M.setup(user_config)
  user_config = user_config or {}
  Config.setup(user_config)

  vim.api.nvim_create_user_command("GoToFactoryBot", function()
    go_to_factory_bot()
  end, {
    nargs = 0,
    force = true,
    desc = "Go to the factory file from model file or factory_bot method call.",
  })
end

return M
