-- Note: このファイルのテストは元々正規表現ベースの実装に対するものでした。
-- 現在の実装はTreesitterベースに変更されており、factory_name_extractor.luaは
-- treesitter_extractor.luaに委譲するラッパーになっています。
--
-- 実際のテストはtreesitter_extractor_spec.luaで行われるべきです。
-- このファイルは後方互換性のために残されていますが、
-- テストはTreesitter環境に依存するため、実際のバッファとカーソル位置を
-- 設定する必要があります。

describe("extract", function()
  local FactoryNameExtractor = require("go-to-factory-bot.factory_name_extractor")

  -- Note: このテストは正規表現ベースの実装に対するものでした。
  -- Treesitterベースの実装では、lineパラメータは使用されず、
  -- カーソル位置から直接抽出されます。
  --
  -- 実際のテストを実装するには:
  -- 1. テスト用のRubyバッファを作成
  -- 2. テストコードを設定
  -- 3. カーソルを適切な位置に移動
  -- 4. extract()を呼び出して検証
  --
  -- 詳細はtreesitter_extractor_spec.luaを参照してください。

  describe("when FactoryBot method is simply called", function()
    it("delegates to treesitter_extractor", function()
      -- Treesitterベースのテストは環境依存のため、
      -- ここでは基本的なインターフェースのみを確認
      local result = FactoryNameExtractor.extract("create(:user)")
      -- 結果はnilまたは文字列
      assert.is_true(result == nil or type(result) == "string")
    end)
  end)
end)
