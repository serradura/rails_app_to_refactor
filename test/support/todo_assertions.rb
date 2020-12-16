# frozen_string_literal: true

module TodoAssertions
  Nil_Or_An_ISO8601_Datetime = -> value do
    value.nil? ? true : value.match?(RegexpPatterns::ISO8601_DATETIME)
  end

  def assert_todo_json_schema(json)
    assert_hash_schema({
      "id" => Integer,
      "title" => String,
      "status" => /\A(active|overdue|completed)\z/,
      "due_at" => Nil_Or_An_ISO8601_Datetime,
      "completed_at" => Nil_Or_An_ISO8601_Datetime,
      "created_at" => RegexpPatterns::ISO8601_DATETIME,
      "updated_at" => RegexpPatterns::ISO8601_DATETIME
    }, json)
  end
end
