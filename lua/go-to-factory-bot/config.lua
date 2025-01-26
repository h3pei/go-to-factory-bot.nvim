local config = {}

local default_config = {
  -- Patterns when determining the factory file name from the factory name.
  --
  -- By default, go-to-factory-bot.nvim looks for a factory file with the plural form of the factory name.
  -- For example, for a factory named "user", look for an ruby file with the plural "users".
  --
  -- If you have your own non-plural rule factory, you can set it up here.
  -- Also, this plugin's plural system conversion is not perfect. If you encounter an inappropriate conversion, please set it here.
  --
  -- Example:
  -- {
  --   ["police"] = "police",
  --   ["man"] = "mans",
  -- }
  custom_factory_name_patterns = {},

  -- Path of the directory where the factory file is located.
  -- In Ruby on Rails, this corresponds to the value set in `Rails.application.config.factory_bot.definition_file_paths`.
  -- see: https://thoughtbot.github.io/factory_bot/ref/find_definitions.html
  definition_file_path = "spec/factories",

  -- Command to open the file to jump to.
  -- Examples of other alternatives: vsplit, split, tabedit
  jump_command = "edit",

  -- Whether to pluralize the factory name when searching for the factory file.
  -- If you set it to false, it will not pluralize the factory name.
  pluralize_factory_name = true,

  -- Suffix of the factory file.
  -- For example, if you specify "factory" as suffix, it will try to find "users_factory.rb" from the "user" factory.
  --
  -- related: https://github.com/thoughtbot/factory_bot_rails/blob/main/README.md#generators
  suffix = "",
}

local Config = {}

function Config.setup(user_config)
  config = vim.tbl_deep_extend("force", default_config, user_config)

  -- FIXME: In Neovim 0.11, the current usage of vim.validate() will be deprecated.
  -- https://neovim.io/doc/user/deprecated.html#deprecated-0.11
  -- https://neovim.io/doc/user/lua.html#vim.validate()
  vim.validate({
    custom_factory_name_patterns = { config.custom_factory_name_patterns, "table" },
    definition_file_path = { config.definition_file_path, "string" },
    jump_command = { config.jump_command, "string" },
    pluralize_factory_name = { config.pluralize_factory_name, "boolean" },
    suffix = { config.suffix, "string" },
  })
end

setmetatable(Config, {
  __index = function(_, key)
    return config[key]
  end,
})

return Config
