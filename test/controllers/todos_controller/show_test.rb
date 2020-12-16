require 'test_helper'

class TodosControllerShowTest < ActionDispatch::IntegrationTest
  include TodoAssertions

  test "should respond with 401 if the user token is invalid" do
    get todo_url(id: 1)

    assert_response 401
  end

  test "should respond with 404 when the todo was not found" do
    user = users(:rodrigo)

    get todo_url(id: 1), {
      headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" },
      params: { title: 'Buy coffee' }
    }

    assert_response 404

    assert_equal(
      { "todo" => { "id" => "not found" } },
      JSON.parse(response.body)
    )
  end

  test "should respond with 200 when finds the record" do
    todo = todos(:uncompleted)

    get todo_url(id: todo.id), {
      headers: { 'Authorization' => "Bearer token=\"#{todo.user.token}\"" }
    }

    assert_response 200

    json = JSON.parse(response.body)

    assert_equal(todo.id, json.dig("todo", "id"))

    assert_hash_schema({ "todo" => Hash }, json)

    assert_todo_json_schema(json["todo"])
  end
end
