# frozen_string_literal: true

module TodoListAssertions
  module JSON
    def assert_todo_list_json(json, default: false)
      assert_hash_schema({
        "id" => Integer,
        "title" => String,
        "default" => default,
        "created_at" => RegexpPatterns::ISO8601_DATETIME,
        "updated_at" => RegexpPatterns::ISO8601_DATETIME
      }, json)
    end
  end

  module Response
    def assert_todo_list_not_found(response:, id:)
      assert_response 404

      expected_json = { "todo_list" => { "id" => id.to_s, "message" => "not found" } }

      assert_equal(expected_json, ::JSON.parse(response.body))
    end

    def assert_todo_list_unprocessable_entity(response:, errors:)
      assert_response 422

      assert_equal({ "todo_list" => errors }, ::JSON.parse(response.body))
    end
  end
end
