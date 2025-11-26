describe("ModelPathAnalyzer", function()
  local ModelPathAnalyzer = require("go-to-factory-bot.model_path_analyzer")

  describe("is_model_file", function()
    it("returns true for app/models/user.rb", function()
      local result = ModelPathAnalyzer.is_model_file("app/models/user.rb")
      assert.is_true(result)
    end)

    it("returns true for app/models/admin/user.rb", function()
      local result = ModelPathAnalyzer.is_model_file("app/models/admin/user.rb")
      assert.is_true(result)
    end)

    it("returns false for spec/models/user_spec.rb", function()
      local result = ModelPathAnalyzer.is_model_file("spec/models/user_spec.rb")
      assert.is_false(result)
    end)

    it("returns false for app/controllers/users_controller.rb", function()
      local result = ModelPathAnalyzer.is_model_file("app/controllers/users_controller.rb")
      assert.is_false(result)
    end)

    it("returns false for lib/some_utility.rb", function()
      local result = ModelPathAnalyzer.is_model_file("lib/some_utility.rb")
      assert.is_false(result)
    end)
  end)

  describe("is_excluded_pattern", function()
    it("returns true for concerns directory", function()
      local result = ModelPathAnalyzer.is_excluded_pattern("app/models/concerns/taggable.rb")
      assert.is_true(result)
    end)

    it("returns true for application_record.rb", function()
      local result = ModelPathAnalyzer.is_excluded_pattern("app/models/application_record.rb")
      assert.is_true(result)
    end)

    it("returns true for files ending with _base.rb", function()
      local result = ModelPathAnalyzer.is_excluded_pattern("app/models/user_base.rb")
      assert.is_true(result)
    end)

    it("returns false for normal model file", function()
      local result = ModelPathAnalyzer.is_excluded_pattern("app/models/user.rb")
      assert.is_false(result)
    end)
  end)

  describe("extract_model_info", function()
    it("extracts model name from simple path", function()
      local model_name, subdirectory, error_message =
        ModelPathAnalyzer.extract_model_info("app/models/user.rb")
      assert.equals(model_name, "user")
      assert.is_nil(subdirectory)
      assert.is_nil(error_message)
    end)

    it("extracts model name and subdirectory from nested path", function()
      local model_name, subdirectory, error_message =
        ModelPathAnalyzer.extract_model_info("app/models/admin/user.rb")
      assert.equals(model_name, "user")
      assert.equals(subdirectory, "admin/")
      assert.is_nil(error_message)
    end)

    it("extracts model name and deep subdirectory", function()
      local model_name, subdirectory, error_message =
        ModelPathAnalyzer.extract_model_info("app/models/api/v1/user.rb")
      assert.equals(model_name, "user")
      assert.equals(subdirectory, "api/v1/")
      assert.is_nil(error_message)
    end)

    it("returns error for concerns directory", function()
      local model_name, subdirectory, error_message =
        ModelPathAnalyzer.extract_model_info("app/models/concerns/taggable.rb")
      assert.is_nil(model_name)
      assert.is_nil(subdirectory)
      assert.equals(error_message, "Concerns are not associated with factory files")
    end)

    it("returns error for application_record.rb", function()
      local model_name, subdirectory, error_message =
        ModelPathAnalyzer.extract_model_info("app/models/application_record.rb")
      assert.is_nil(model_name)
      assert.is_nil(subdirectory)
      assert.equals(error_message, "Base classes are not associated with factory files")
    end)

    it("returns error for _base.rb files", function()
      local model_name, subdirectory, error_message =
        ModelPathAnalyzer.extract_model_info("app/models/user_base.rb")
      assert.is_nil(model_name)
      assert.is_nil(subdirectory)
      assert.equals(error_message, "Base classes are not associated with factory files")
    end)

    it("returns error for non-model file", function()
      local model_name, subdirectory, error_message =
        ModelPathAnalyzer.extract_model_info("app/controllers/users_controller.rb")
      assert.is_nil(model_name)
      assert.is_nil(subdirectory)
      assert.equals(error_message, "Not a model file")
    end)
  end)
end)
