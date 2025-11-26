local config = {}

local default_config = {
  -- Patterns when determining the factory file name from the factory name.
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

  -- Command to open the file to jump to.
  -- Examples of other alternatives: vsplit, split, tabedit
  jump_command = "edit",

  -- Whether to suppress error messages.
  -- If you set it to true, error messages will not be displayed.
  silent = false,
}

local Config = {}

function Config.setup(user_config)
  config = vim.tbl_deep_extend("force", default_config, user_config)

  -- FIXME: In Neovim 0.11, the current usage of vim.validate() will be deprecated.
  -- https://neovim.io/doc/user/deprecated.html#deprecated-0.11
  -- https://neovim.io/doc/user/lua.html#vim.validate()
  vim.validate({
    custom_factory_name_patterns = { config.custom_factory_name_patterns, "table" },
    jump_command = { config.jump_command, "string" },
    silent = { config.silent, "boolean" },
  })
end

setmetatable(Config, {
  __index = function(_, key)
    return config[key]
  end,
})

return Config
