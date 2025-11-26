describe("extract", function()
  local FactoryNameExtractor = require("go-to-factory-bot.factory_name_extractor")
  local bufnr

  -- テスト用のバッファとカーソル位置を設定するヘルパー関数
  local function setup_test_buffer(line_content, cursor_col)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, "filetype", "ruby")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { line_content })

    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, bufnr)
    -- カーソル位置を設定（デフォルトはメソッド名の位置）
    vim.api.nvim_win_set_cursor(win, { 1, cursor_col or 0 })

    return bufnr
  end

  after_each(function()
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end)

  describe("when FactoryBot method is simply called", function()
    it("returns factory name for create", function()
      bufnr = setup_test_buffer("create(:user)", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for build", function()
      bufnr = setup_test_buffer("build(:user)", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for build_stubbed", function()
      bufnr = setup_test_buffer("build_stubbed(:user)", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for attributes_for", function()
      bufnr = setup_test_buffer("attributes_for(:user)", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)
  end)

  describe("when FactoryBot method is called with traits", function()
    it("returns factory name for create", function()
      bufnr = setup_test_buffer("create(:user, :admin)", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for build", function()
      bufnr = setup_test_buffer("build(:user, :admin)", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for build_stubbed", function()
      bufnr = setup_test_buffer("build_stubbed(:user, :admin)", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for attributes_for", function()
      bufnr = setup_test_buffer("attributes_for(:user, :admin)", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)
  end)

  describe("when FactoryBot method is called with attributes", function()
    it("returns factory name for create", function()
      bufnr = setup_test_buffer("create(:user, name: 'Bob')", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for build", function()
      bufnr = setup_test_buffer("build(:user, name: 'Bob')", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for build_stubbed", function()
      bufnr = setup_test_buffer("build_stubbed(:user, name: 'Bob')", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for attributes_for", function()
      bufnr = setup_test_buffer("attributes_for(:user, name: 'Bob')", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)
  end)

  describe("when FactoryBot method is called with traits and attributes", function()
    it("returns factory name for create", function()
      bufnr = setup_test_buffer("create(:user, :admin, name: 'Bob')", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for build", function()
      bufnr = setup_test_buffer("build(:user, :admin, name: 'Bob')", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for build_stubbed", function()
      bufnr = setup_test_buffer("build_stubbed(:user, :admin, name: 'Bob')", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for attributes_for", function()
      bufnr = setup_test_buffer("attributes_for(:user, :admin, name: 'Bob')", 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)
  end)

  describe("when other strings are present before the FactoryBot method call", function()
    it("returns factory name for create", function()
      bufnr = setup_test_buffer("let(:current_user) { create(:user) }", 21)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for build", function()
      bufnr = setup_test_buffer("let(:current_user) { build(:user) }", 21)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for build_stubbed", function()
      bufnr = setup_test_buffer("let(:current_user) { build_stubbed(:user) }", 21)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name for attributes_for", function()
      bufnr = setup_test_buffer("let(:current_user) { attributes_for(:user) }", 21)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)
  end)

  describe("when factory name contains hyphen", function()
    it("converts hyphen to underscore", function()
      bufnr = setup_test_buffer('create(:"user-profile")', 0)
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user_profile")
    end)
  end)

  describe("when method call spans multiple lines", function()
    it("returns factory name", function()
      bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(bufnr, "filetype", "ruby")
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
        "create(",
        "  :user,",
        "  :admin",
        ")",
      })
      local win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, bufnr)
      vim.api.nvim_win_set_cursor(win, { 1, 0 })

      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)
  end)

  describe("when cursor is on whitespace", function()
    it("returns factory name when cursor is on whitespace before method", function()
      bufnr = setup_test_buffer("    create(:user)", 0)  -- カーソルがインデント上
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)

    it("returns factory name when cursor is on whitespace after method", function()
      bufnr = setup_test_buffer("create(:user)    ", 16)  -- カーソルが末尾の空白上
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)
  end)

  describe("when multiple FactoryBot methods on same line", function()
    it("returns first factory name when multiple calls on same line", function()
      bufnr = setup_test_buffer("create(:user); build(:admin)", 20)  -- カーソルが後半
      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")  -- 最初のものを選択
    end)
  end)

  describe("when cursor is on second line of multi-line method call", function()
    it("returns factory name when cursor is on argument line", function()
      bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(bufnr, "filetype", "ruby")
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
        "create(",
        "  :user,",
        "  :admin",
        ")",
      })
      local win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, bufnr)
      vim.api.nvim_win_set_cursor(win, { 2, 2 })  -- カーソルを2行目に配置

      local result = FactoryNameExtractor.extract()
      assert.are.same(result, "user")
    end)
  end)
end)
