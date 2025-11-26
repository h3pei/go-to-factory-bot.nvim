local Config = require("go-to-factory-bot.config")
local FactoryNameExtractor = require("go-to-factory-bot.factory_name_extractor")
local FactoryPathFinder = require("go-to-factory-bot.factory_path_finder")

local M = {}

local function notify(message, level)
  if not Config.silent then
    vim.notify(message, level)
  end
end

local function go_to_factory_bot()
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

function M.setup(user_config)
  user_config = user_config or {}
  Config.setup(user_config)

  vim.api.nvim_create_user_command("GoToFactoryBot", function()
    go_to_factory_bot()
  end, { nargs = 0, force = true, desc = "Go to the factory_bot file from the line containing the factory_bot method call." })
end

return M
