require 'test_helper'

class TodosControllerDestroyTest < ActionDispatch::IntegrationTest
  include TodoAssertions

  test "should respond with 401 if the user token is invalid" do
    delete todo_url(id: 1)

    assert_response 401
  end

  test "should respond with 404 when the todo was not found" do
    user = users(:rodrigo)

    delete todo_url(id: 1), headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" }

    assert_response 404

    assert_equal(
      { "todo" => { "id" => "not found" } },
      JSON.parse(response.body)
    )
  end

  test "should respond with 200 after deletes an existing todo" do
    todo = todos(:incomplete)

    assert_difference 'Todo.count', -1 do
      delete todo_url(todo), headers: { 'Authorization' => "Bearer token=\"#{todo.user.token}\"" }
    end

    assert_response 200

    json = JSON.parse(response.body)

    assert_hash_schema({ "todo" => Hash }, json)

    assert_todo_json_schema(json["todo"])
  end
end
