require 'test_helper'

class TodosControllerActivateTest < ActionDispatch::IntegrationTest
  include TodoAssertions

  test "should respond with 401 if the user token is invalid" do
    put activate_todo_url(id: 1)

    assert_response 401
  end

  test "should respond with 404 when the todo was not found" do
    user = users(:rodrigo)

    put activate_todo_url(id: 1), headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" }

    assert_response 404

    assert_equal(
      { "todo" => { "id" => "not found" } },
      JSON.parse(response.body)
    )
  end

  test "should respond with 200 after completes an existing todo" do
    todo = todos(:completed)

    put activate_todo_url(todo), headers: { 'Authorization' => "Bearer token=\"#{todo.user.token}\"" }

    assert_response 200

    todo.reload

    assert_predicate(todo, :active?)

    json = JSON.parse(response.body)

    assert_hash_schema({ "todo" => Hash }, json)

    assert_todo_json_schema(json["todo"])
  end
end
