require 'test_helper'

class TodosControllerIndexTest < ActionDispatch::IntegrationTest
  include TodoAssertions

  def assert_todos_json_schema(json)
    assert_hash_schema({"todos" => Array}, json)

    json["todos"].each { |item| assert_todo_json_schema(item) }
  end

  test "should respond with 401 if the user token is invalid" do
    get todos_url

    assert_response 401
  end

  test "should respond with 200 even when the user hasn't to-dos" do
    user = users(:rodrigo)

    get todos_url, headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" }

    assert_response 200

    assert_equal(
      { "todos" => [] },
      JSON.parse(response.body)
    )
  end

  test "should respond with 200 when the user has to-dos and there is no status to filter" do
    user = users(:john_doe)

    get todos_url, headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" }

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(4, json["todos"].size)
  end

  test "should respond with 200 when the user has to-dos and the given status is uncompleted" do
    user = users(:john_doe)

    get todos_url, headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" }, params: { status: 'uncompleted' }

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(2, json["todos"].size)
  end

  test "should respond with 200 whenthe user has to-dos and the given status is completed" do
    user = users(:john_doe)

    get todos_url, headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" }, params: { status: 'completed' }

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(2, json["todos"].size)

    assert(json["todos"].all? { |todo| todo['completed_at'].present? })
  end

  test "should respond with 200 whenthe user has to-dos and the given status is overdue" do
    user = users(:john_doe)

    get todos_url, headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" }, params: { status: 'overdue' }

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(1, json["todos"].size)

    assert(json["todos"].all? { |todo| todo['completed_at'].blank? })
  end
end
