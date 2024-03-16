# go-to-factory-bot.nvim

`go-to-factory-bot.nvim` is a Neovim plugin that provides the ability to jump to the [factory_bot](https://github.com/thoughtbot/factory_bot) definition file from lines calling factory_bot methods such as `#create` and `#build`.

![go-to-factory-bot-nvim-demo](https://github.com/mogulla3/go-to-factory-bot.nvim/assets/1377455/0076ef91-0390-4f15-ab45-668e710e4ad0)

## Usecase

For example, suppose you are editing an RSpec file that uses factory_bot as follows:

```ruby
let(:user) { create(:user, :admin, name: "Bob") }
```

Sometimes you will want to check how the `:admin` trait is defined and what the default values are for unspecified attributes other than `name`.

In this case, you can run the `:GoToFactoryBot` command on this line to jump to the user factory file (typically `spec/factories/users.rb`).

## Installation

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ "mogulla3/go-to-factory-bot.nvim" }
```

[vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug "mogulla3/go-to-factory-bot.nvim"
```

Once installed, the `setup` function should be called as follows:

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

  -- Suffix of the factory file.
  -- For example, if you specify "factory" as suffix, it will try to find "users_factory.rb" from the "user" factory.
  --
  -- related: https://github.com/thoughtbot/factory_bot_rails/blob/main/README.md#generators
  suffix = "",
})
```
