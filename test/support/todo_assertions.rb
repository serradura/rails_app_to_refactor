# frozen_string_literal: true

module TodoAssertions
  module JSON
    Nil_Or_An_ISO8601_Datetime = -> value do
      value.nil? ? true : value.match?(RegexpPatterns::ISO8601_DATETIME)
    end

    def assert_todo_json(json)
      assert_hash_schema({
        "id" => Integer,
        "title" => String,
        "status" => /\A(overdue|completed|incomplete)\z/,
        "due_at" => Nil_Or_An_ISO8601_Datetime,
        "completed_at" => Nil_Or_An_ISO8601_Datetime,
        "created_at" => RegexpPatterns::ISO8601_DATETIME,
        "updated_at" => RegexpPatterns::ISO8601_DATETIME,
        "todo_list_id" => Integer
      }, json)
    end
  end

  module Response
    def assert_todo_not_found(response:, id:)
      assert_response 404

      expected_json = { "todo" => { "id" => id.to_s, "message" => "not found" } }

      assert_equal(expected_json, ::JSON.parse(response.body))
    end

    def assert_todo_bad_request(response:)
      assert_response 400

      expected_json = { "error" => "param is missing or the value is empty: todo" }

      assert_equal(expected_json, ::JSON.parse(response.body))
    end

    def assert_todo_unprocessable_entity(response:, errors:)
      assert_response 422

      assert_equal({ "todo" => errors }, ::JSON.parse(response.body))
    end
  end
end
