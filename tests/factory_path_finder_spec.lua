describe("find_by_name", function()
  local FactoryPathFinder = require("go-to-factory-bot.factory_path_finder")

  before_each(function()
    vim.fn.mkdir("spec/factories", "p")
  end)

  after_each(function()
    vim.fn.delete("spec", "rf")
    if vim.fn.isdirectory("app") == 1 then
      vim.fn.delete("app", "rf")
    end
  end)

  it("returns factory_file path when factory_file exists", function()
    vim.fn.writefile({}, "spec/factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user", "spec/factories"), "spec/factories/users.rb")
  end)

  it("returns nil when factory_file does not exist", function()
    vim.fn.writefile({}, "spec/factories/dummy_users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user", "spec/factories"), nil)
  end)
end)

describe("multi-pattern search", function()
  local FactoryPathFinder = require("go-to-factory-bot.factory_path_finder")

  before_each(function()
    vim.fn.mkdir("spec/factories", "p")
  end)

  after_each(function()
    vim.fn.delete("spec", "rf")
    if vim.fn.isdirectory("app") == 1 then
      vim.fn.delete("app", "rf")
    end
  end)

  it("finds singular file when only singular exists", function()
    vim.fn.writefile({}, "spec/factories/user.rb")
    assert.equals(FactoryPathFinder.find_by_name("user", "spec/factories"), "spec/factories/user.rb")
  end)

  it("finds plural file when only plural exists", function()
    vim.fn.writefile({}, "spec/factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user", "spec/factories"), "spec/factories/users.rb")
  end)

  it("finds {plural}_factory.rb", function()
    vim.fn.writefile({}, "spec/factories/users_factory.rb")
    assert.equals(FactoryPathFinder.find_by_name("user", "spec/factories"), "spec/factories/users_factory.rb")
  end)

  it("finds {singular}_factory.rb", function()
    vim.fn.writefile({}, "spec/factories/user_factory.rb")
    assert.equals(FactoryPathFinder.find_by_name("user", "spec/factories"), "spec/factories/user_factory.rb")
  end)

  it("prefers plural over other patterns", function()
    -- 複数のファイルがある場合、優先順位通り
    vim.fn.writefile({}, "spec/factories/users.rb")
    vim.fn.writefile({}, "spec/factories/user.rb")
    vim.fn.writefile({}, "spec/factories/users_factory.rb")
    assert.equals(FactoryPathFinder.find_by_name("user", "spec/factories"), "spec/factories/users.rb")
  end)

  it("does not find files outside of definition_file_path", function()
    -- app/models/user.rb は見つけない（安全性の確認）
    vim.fn.mkdir("app/models", "p")
    vim.fn.writefile({}, "app/models/user.rb")
    assert.equals(FactoryPathFinder.find_by_name("user", "spec/factories"), nil)
  end)
end)
