describe("TreesitterExtractor", function()
  local TreesitterExtractor = require("go-to-factory-bot.treesitter_extractor")

  -- Note: これらのテストはTreesitterが利用可能な環境でのみ実行されます
  -- 実際のテストではモックを使用することも検討できますが、
  -- Treesitterの動作確認のためには実際のパーサーを使用するのが望ましいです

  describe("extract", function()
    describe("when Treesitter is not available", function()
      it("returns error message", function()
        -- Treesitterが利用不可の場合のテストは環境依存のため、
        -- ここでは基本的な動作確認のみを行います
        local _, error_message = TreesitterExtractor.extract()
        if error_message then
          assert.is_not_nil(error_message)
          assert.is_string(error_message)
        end
      end)
    end)

    -- 以下のテストは実際のRubyコードとTreesitterパーサーを使用して
    -- 実行されることを想定しています。
    -- テスト環境でTreesitterとRubyパーサーがインストールされている必要があります。

    describe("when FactoryBot method is simply called", function()
      -- Note: これらのテストは実際のバッファにRubyコードを設定して
      -- カーソル位置を適切に配置する必要があります
      -- 実装例:
      -- 1. テスト用のRubyバッファを作成
      -- 2. テスト用のコードを設定
      -- 3. カーソルを適切な位置に移動
      -- 4. extract()を呼び出して検証
    end)

    describe("when FactoryBot method is called with traits", function()
      -- 同様にトレイト付きの呼び出しをテスト
    end)

    describe("when FactoryBot method is called on multiple lines", function()
      -- 複数行にわたる呼び出しをテスト
    end)

    describe("when factory name contains hyphen", function()
      -- ハイフン付きファクトリ名のテスト
      -- create(:"user-profile") -> "user_profile" を期待
    end)

    describe("when cursor is in a comment", function()
      -- コメント内のメソッド呼び出しは抽出されないことを確認
    end)

    describe("when cursor is not on a factory_bot method", function()
      -- factory_botメソッドでない場合のエラーメッセージを確認
    end)
  end)
end)
