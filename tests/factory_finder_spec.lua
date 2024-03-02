describe("find_by_name", function()
  local FactoryFinder = require("go-to-factory-bot.factory_finder")

  before_each(function()
    vim.fn.mkdir("spec/factories", "p")
  end)

  after_each(function()
    vim.fn.delete("spec", "rf")
  end)

  it("returns factory_file path when factory_file exists", function()
    vim.fn.writefile({}, "spec/factories/users.rb")
    assert.equals(FactoryFinder.find_by_name("user", "spec/factories", ""), "spec/factories/users.rb")
  end)

  it("returns nil when factory_file does not exist", function()
    vim.fn.writefile({}, "spec/factories/dummy_users.rb")
    assert.equals(FactoryFinder.find_by_name("user", "spec/factories", ""), nil)
  end)

  it("returns factory_file path when factory_file with suffix exists", function()
    vim.fn.writefile({}, "spec/factories/users_factory.rb")
    assert.equals(FactoryFinder.find_by_name("user", "spec/factories", "_factory"), "spec/factories/users_factory.rb")
  end)

  it("returns nil when factory_file with suffix does not exist", function()
    vim.fn.writefile({}, "spec/factories/users.rb")
    assert.equals(FactoryFinder.find_by_name("user", "spec/factories", "_factory"), nil)
  end)
end)
