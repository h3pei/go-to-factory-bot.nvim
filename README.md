# go-to-factory-bot.nvim

`go-to-factory-bot.nvim` is a Neovim plugin that provides the ability to jump to the [factory_bot](https://github.com/thoughtbot/factory_bot) definition file from lines calling factory_bot methods such as `#create` and `#build`.

This plugin uses Treesitter to accurately parse Ruby code, supporting complex syntax including multi-line method calls and hyphenated factory names.

![go-to-factory-bot-nvim-demo-v2](https://github.com/h3pei/go-to-factory-bot.nvim/assets/1377455/f927117e-3bc9-487d-a24a-b8f327901647)

## Usecase

For example, suppose you are editing an RSpec file that uses factory_bot as follows:

```ruby
let(:user) { create(:user, :admin, name: "Bob") }
```

Sometimes you will want to check how the `:admin` trait is defined and what the default values are for unspecified attributes other than `name`.

In this case, you can run the `:GoToFactoryBot` command on this line to jump to the user factory file (typically `spec/factories/users.rb`).

## Requirements

**This plugin requires Treesitter** to parse Ruby code accurately.

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Ruby parser for Treesitter (install with `:TSInstall ruby`)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "h3pei/go-to-factory-bot.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require('go-to-factory-bot').setup()
  end,
}
```

After installing the plugin, make sure to install the Ruby parser:

```vim
:TSInstall ruby
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'h3pei/go-to-factory-bot.nvim'
```

After installing, run:

```vim
:TSInstall ruby
```

Then call the setup function:

```lua
require('go-to-factory-bot').setup()
```

Some settings can be customised. See [Configuration](#Configuration) for more information.

## Usage / Command

This plugin only provides `:GoToFactoryBot` command.

So, simply run this command on the line containing the factory_bot method call.

It may be more convenient to define a shortcut command called `:GF` as follows.
```lua
vim.api.nvim_create_user_command("GF", "GoToFactoryBot", {})
```

## Features

### Supported Syntax

Thanks to Treesitter, this plugin accurately handles:

- **Single-line calls**: `create(:user)`
- **Multi-line calls**:
  ```ruby
  create(
    :user,
    :admin
  )
  ```
- **Hyphenated factory names**: `create(:"user-profile")` → jumps to `user_profiles.rb`
- **Traits and attributes**: `create(:user, :admin, name: 'Bob')`
- **Comment exclusion**: Method calls in comments are automatically ignored

### Supported Methods

- `create`
- `build`
- `build_stubbed`
- `attributes_for`

## Configuration

The following are the settings and their default values:

```lua
require('go-to-factory-bot').setup({
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

  -- Whether to suppress error messages.
  -- If you set it to true, error messages will not be displayed.
  silent = false,

  -- Suffix of the factory file.
  -- For example, if you specify "factory" as suffix, it will try to find "users_factory.rb" from the "user" factory.
  --
  -- related: https://github.com/thoughtbot/factory_bot_rails/blob/main/README.md#generators
  suffix = "",
})
```

## Troubleshooting

### Error: "Treesitter is not available"

This error occurs when Treesitter is not installed or the Ruby parser is not available.

**Solution:**

1. Install nvim-treesitter:
   ```vim
   :Lazy install nvim-treesitter
   ```

2. Install the Ruby parser:
   ```vim
   :TSInstall ruby
   ```

3. Verify the installation:
   ```vim
   :TSInstallInfo ruby
   ```

### Error: "No method call found at cursor"

This error occurs when the cursor is not positioned on a factory_bot method call.

**Solution:**

Make sure your cursor is on or within a factory_bot method call (e.g., `create(:user)`).

### Error: "Factory file not found"

This error occurs when the factory file does not exist in the configured directory.

**Solution:**

1. Check that the factory file exists in the configured `definition_file_path` directory (default: `spec/factories`)
2. Verify the file name matches the pluralized factory name (e.g., `users.rb` for `:user`)
3. If using a custom naming convention, configure `custom_factory_name_patterns` or `suffix`
