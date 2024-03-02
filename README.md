# go-to-factory-bot.nvim

`go-to-factory-bot.nvim` is a Neovim plugin that provides the ability to jump to a [factory_bot](https://github.com/thoughtbot/factory_bot) definition file from a line containing a factory_bot method call such as `#create` or `#build`.

For example, imagine a situation where you are editing an RSpec file containing lines such as:

```ruby
let(:user) { create(:user, :admin, name: "Bob") }
```
And at this point, if you run the command `:FactoryBotJump` with the cursor over this line, it will jump to the user factory file (typically `spec/factories/users.rb`).

## Installation

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "mogulla3/go-to-factory-bot.nvim" }
```

[vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug "mogulla3/go-to-factory-bot.nvim"
```

Otherwise, install with your preferred plugin manager.
Once installed, the `setup` function should be called as follows:

```lua
require('go-to-factory-bot').setup()
```

Some settings can be customised. See [#Configuration] for more information.

## Usage / Command

This plugin only provides `:FactoryBotJump` command!

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

  -- Suffix of the factory file.
  -- For example, if you specify "factory" as suffix, it will try to find "users_factory.rb" from the "user" factory.
  --
  -- related: https://github.com/thoughtbot/factory_bot_rails/blob/main/README.md#generators
  suffix = "",
})
```
