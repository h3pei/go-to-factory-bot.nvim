describe("find_by_name", function()
  local FactoryPathFinder = require("go-to-factory-bot.factory_path_finder")

  before_each(function()
    vim.fn.mkdir("spec/factories", "p")
  end)

  after_each(function()
    if vim.fn.isdirectory("spec") == 1 then
      vim.fn.delete("spec", "rf")
    end
    if vim.fn.isdirectory("test") == 1 then
      vim.fn.delete("test", "rf")
    end
    if vim.fn.isdirectory("factories") == 1 then
      vim.fn.delete("factories", "rf")
    end
    if vim.fn.isdirectory("app") == 1 then
      vim.fn.delete("app", "rf")
    end
  end)

  it("returns factory_file path when factory_file exists", function()
    vim.fn.writefile({}, "spec/factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "spec/factories/users.rb")
  end)

  it("returns nil when factory_file does not exist", function()
    vim.fn.writefile({}, "spec/factories/dummy_users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), nil)
  end)
end)

describe("multi-pattern search", function()
  local FactoryPathFinder = require("go-to-factory-bot.factory_path_finder")

  before_each(function()
    vim.fn.mkdir("spec/factories", "p")
  end)

  after_each(function()
    if vim.fn.isdirectory("spec") == 1 then
      vim.fn.delete("spec", "rf")
    end
    if vim.fn.isdirectory("test") == 1 then
      vim.fn.delete("test", "rf")
    end
    if vim.fn.isdirectory("factories") == 1 then
      vim.fn.delete("factories", "rf")
    end
    if vim.fn.isdirectory("app") == 1 then
      vim.fn.delete("app", "rf")
    end
  end)

  it("finds singular file when only singular exists", function()
    vim.fn.writefile({}, "spec/factories/user.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "spec/factories/user.rb")
  end)

  it("finds plural file when only plural exists", function()
    vim.fn.writefile({}, "spec/factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "spec/factories/users.rb")
  end)

  it("finds {plural}_factory.rb", function()
    vim.fn.writefile({}, "spec/factories/users_factory.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "spec/factories/users_factory.rb")
  end)

  it("finds {singular}_factory.rb", function()
    vim.fn.writefile({}, "spec/factories/user_factory.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "spec/factories/user_factory.rb")
  end)

  it("prefers plural over other patterns", function()
    -- 複数のファイルがある場合、優先順位通り
    vim.fn.writefile({}, "spec/factories/users.rb")
    vim.fn.writefile({}, "spec/factories/user.rb")
    vim.fn.writefile({}, "spec/factories/users_factory.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "spec/factories/users.rb")
  end)

  it("does not find files outside of definition_file_path", function()
    -- app/models/user.rb は見つけない（安全性の確認）
    vim.fn.mkdir("app/models", "p")
    vim.fn.writefile({}, "app/models/user.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), nil)
  end)
end)

describe("multi-directory search", function()
  local FactoryPathFinder = require("go-to-factory-bot.factory_path_finder")

  after_each(function()
    if vim.fn.isdirectory("spec") == 1 then
      vim.fn.delete("spec", "rf")
    end
    if vim.fn.isdirectory("test") == 1 then
      vim.fn.delete("test", "rf")
    end
    if vim.fn.isdirectory("factories") == 1 then
      vim.fn.delete("factories", "rf")
    end
  end)

  it("finds file in spec/factories", function()
    vim.fn.mkdir("spec/factories", "p")
    vim.fn.writefile({}, "spec/factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "spec/factories/users.rb")
  end)

  it("finds file in test/factories", function()
    vim.fn.mkdir("test/factories", "p")
    vim.fn.writefile({}, "test/factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "test/factories/users.rb")
  end)

  it("finds file in factories", function()
    vim.fn.mkdir("factories", "p")
    vim.fn.writefile({}, "factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "factories/users.rb")
  end)

  it("prefers spec/factories over test/factories", function()
    vim.fn.mkdir("spec/factories", "p")
    vim.fn.mkdir("test/factories", "p")
    vim.fn.writefile({}, "spec/factories/users.rb")
    vim.fn.writefile({}, "test/factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "spec/factories/users.rb")
  end)

  it("prefers test/factories over factories", function()
    vim.fn.mkdir("test/factories", "p")
    vim.fn.mkdir("factories", "p")
    vim.fn.writefile({}, "test/factories/users.rb")
    vim.fn.writefile({}, "factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name("user"), "test/factories/users.rb")
  end)
end)

describe("find_by_name_with_namespace", function()
  local FactoryPathFinder = require("go-to-factory-bot.factory_path_finder")

  after_each(function()
    if vim.fn.isdirectory("spec") == 1 then
      vim.fn.delete("spec", "rf")
    end
    if vim.fn.isdirectory("test") == 1 then
      vim.fn.delete("test", "rf")
    end
    if vim.fn.isdirectory("factories") == 1 then
      vim.fn.delete("factories", "rf")
    end
  end)

  it("finds namespaced factory file", function()
    vim.fn.mkdir("spec/factories/admin", "p")
    vim.fn.writefile({}, "spec/factories/admin/users.rb")
    assert.equals(FactoryPathFinder.find_by_name_with_namespace("user", "admin/"), "spec/factories/admin/users.rb")
  end)

  it("finds factory in deep subdirectory", function()
    vim.fn.mkdir("spec/factories/api/v1", "p")
    vim.fn.writefile({}, "spec/factories/api/v1/users.rb")
    assert.equals(
      FactoryPathFinder.find_by_name_with_namespace("user", "api/v1/"),
      "spec/factories/api/v1/users.rb"
    )
  end)

  it("falls back to root when namespaced file not found", function()
    vim.fn.mkdir("spec/factories", "p")
    vim.fn.writefile({}, "spec/factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name_with_namespace("user", "admin/"), "spec/factories/users.rb")
  end)

  it("prefers namespaced over root", function()
    vim.fn.mkdir("spec/factories/admin", "p")
    vim.fn.writefile({}, "spec/factories/admin/users.rb")
    vim.fn.writefile({}, "spec/factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name_with_namespace("user", "admin/"), "spec/factories/admin/users.rb")
  end)

  it("respects pattern priority in namespaced search", function()
    vim.fn.mkdir("spec/factories/admin", "p")
    vim.fn.writefile({}, "spec/factories/admin/users.rb")
    vim.fn.writefile({}, "spec/factories/admin/user.rb")
    assert.equals(
      FactoryPathFinder.find_by_name_with_namespace("user", "admin/"),
      "spec/factories/admin/users.rb"
    )
  end)

  it("works without subdirectory (nil)", function()
    vim.fn.mkdir("spec/factories", "p")
    vim.fn.writefile({}, "spec/factories/users.rb")
    assert.equals(FactoryPathFinder.find_by_name_with_namespace("user", nil), "spec/factories/users.rb")
  end)

  it("returns nil when no file found", function()
    vim.fn.mkdir("spec/factories", "p")
    assert.equals(FactoryPathFinder.find_by_name_with_namespace("user", "admin/"), nil)
  end)
end)
