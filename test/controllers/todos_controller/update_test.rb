require 'test_helper'

class TodosControllerUpdateTest < ActionDispatch::IntegrationTest
  include TodoAssertions

  test "responds with 401 when user token is invalid" do
    put todo_url(id: 1)

    assert_response 401
  end

  test "responds with 400 when to-do parameters are missing" do
    todo = todos(:incomplete)

    put todo_url(todo),
      headers: { 'Authorization' => "Bearer token=\"#{todo.user.token}\"" },
      params: { title: 'Buy coffee' }

    assert_response 400

    assert_equal(
      { "error" => "param is missing or the value is empty: todo" },
      JSON.parse(response.body)
    )
  end

  test "responds with 404 when to-do not found" do
    user = users(:rodrigo)

    put todo_url(id: 1),
      headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" },
      params: { title: 'Buy coffee' }

    assert_response 404

    assert_equal(
      { "todo" => { "id" => "not found" } },
      JSON.parse(response.body)
    )
  end

  test "responds with 422 when invalid parameters are received" do
    todo = todos(:incomplete)

    put todo_url(todo),
      headers: { 'Authorization' => "Bearer token=\"#{todo.user.token}\"" },
      params: { todo: { title: '' } }

    assert_response 422

    assert_equal(
      { "todo" => { "title"=>["can't be blank"] } },
      JSON.parse(response.body)
    )
  end

  test "responds with 200 when a valid description is received" do
    todo = todos(:incomplete)

    first_title = todo.title
    second_title = 'Buy coffee'

    put todo_url(todo),
      headers: { 'Authorization' => "Bearer token=\"#{todo.user.token}\"" },
      params: { todo: { title: second_title } }

    assert_response 200

    json1 = JSON.parse(response.body)
    todo_found1 = Todo.find(json1.dig('todo', 'id'))

    assert_equal(todo.id, todo_found1.id)
    assert_equal(second_title, todo_found1.title)

    assert_todo_json_schema(json1["todo"])

    assert_predicate(json1["todo"]["completed_at"], :blank?)

    # --

    put todo_url(todo),
      headers: { 'Authorization' => "Bearer token=\"#{todo.user.token}\"" },
      params: { todo: { completed: true } }

    assert_response 200

    json2 = JSON.parse(response.body)

    todo_found2 = Todo.find(json2.dig('todo', 'id'))

    assert_equal(todo.id, todo_found2.id)
    assert_predicate(todo_found2, :completed?)

    assert_todo_json_schema(json2["todo"])

    assert_predicate(json2["todo"]["completed_at"], :present?)

    # --

    put todo_url(todo),
      headers: { 'Authorization' => "Bearer token=\"#{todo.user.token}\"" },
      params: { todo: { title: first_title, completed: false } }

    assert_response 200

    json3 = JSON.parse(response.body)

    todo_found3 = Todo.find(json2.dig('todo', 'id'))

    assert_equal(todo.id, todo_found3.id)
    assert_equal(first_title, todo_found3.title)
    assert_predicate(todo_found3, :incomplete?)

    assert_todo_json_schema(json3["todo"])

    assert_equal(first_title, json3["todo"]["title"])

    assert_predicate(json3["todo"]["completed_at"], :blank?)
  end
end
