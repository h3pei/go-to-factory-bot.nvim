local config = {}

local default_config = {
  custom_patterns = {},
  definition_file_path = "spec/factories",
  jump_command = "edit",
  suffix = "",
}

local Config = {}

function Config.setup(user_config)
  config = vim.tbl_deep_extend("force", default_config, user_config)

  vim.validate({
    custom_patterns = { config.custom_patterns, 'table' },
    definition_file_path = { config.definition_file_path, 'string' },
    jump_command = { config.jump_command, 'string' },
    suffix = { config.suffix, 'string' },
  })
end

setmetatable(Config, {
  __index = function(_, key)
    return config[key]
  end,
})

return Config
