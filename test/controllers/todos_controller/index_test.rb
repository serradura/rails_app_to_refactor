require 'test_helper'

class TodosControllerIndexTest < ActionDispatch::IntegrationTest
  include TodoAssertions

  def get_todos(user, params:)
    get(todos_url, headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" }, params:)
  end

  def assert_todos_json_schema(json)
    assert_hash_schema({"todos" => Array}, json)

    json["todos"].each { |item| assert_todo_json_schema(item) }
  end

  def assert_todos_json_order(relation, response, **sort_by)
    json = response.is_a?(Hash) ? response : JSON.parse(response.body)

    assert_todos_json_schema(json)

    todos = relation.is_a?(User) ? relation.todos : relation

    assert_equal(
      todos.order(sort_by).map(&:id),
      json['todos'].map { |todo| todo['id'] },
      sort_by.inspect
    )
  end

  def get_and_assert_todos_order(user, column_name:)
    prepare_param = ->(str) do
      [str.capitalize, str.upcase, str].sample.then { [" #{_1}", " #{_1} ", " #{_1} "].sample }
    end

    sort_by = prepare_param.(column_name)

    ##
    # DEFAULT
    #
    get_todos(user, params: { sort_by: })

    assert_response 200

    assert_todos_json_order(user, response, column_name => :desc)

    ##
    # DESC
    #
    get_todos(user, params: { sort_by:, order: prepare_param.('desc') })

    assert_response 200

    assert_todos_json_order(user, response, column_name => :desc)

    ##
    # ASC
    #
    get_todos(user, params: { sort_by:, order: prepare_param.('asc') })

    assert_response 200

    assert_todos_json_order(user, response, column_name => :asc)
  end

  test "responds with 401 when the user token is invalid" do
    get todos_url

    assert_response 401
  end

  test "responds with 200 even when the user has no to-dos" do
    user = users(:rodrigo)

    get_todos(user, params: {})

    assert_response 200

    assert_equal(
      { "todos" => [] },
      JSON.parse(response.body)
    )
  end

  test "responds with 200 when the user has to-dos and no filter status is applied" do
    user = users(:john_doe)

    get_todos(user, params: {})

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(4, json["todos"].size)
  end

  test "responds with 200 when the user has to-dos and the filter status is set to 'incomplete'" do
    user = users(:john_doe)

    get_todos(user, params: { status: 'incomplete' })

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(2, json["todos"].size)
  end

  test "responds with 200 when the user has to-dos and the filter status is set to 'completed'" do
    user = users(:john_doe)

    get_todos(user, params: { status: 'completed' })

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(2, json["todos"].size)

    assert(json["todos"].all? { |todo| todo['completed_at'].present? })
  end

  test "responds with 200 when the user has to-dos and the filter status is set to 'overdue'" do
    user = users(:john_doe)

    get_todos(user, params: { status: 'overdue' })

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(1, json["todos"].size)

    assert(json["todos"].all? { |todo| todo['completed_at'].blank? })
  end

  test "responds with 200 when the user has to-dos and the sort_by is set to 'title'" do
    user = users(:john_doe)

    get_and_assert_todos_order(user, column_name: 'title')
  end

  test "responds with 200 when the user has to-dos and the sort_by is set to 'due_at'" do
    user = users(:john_doe)

    get_and_assert_todos_order(user, column_name: 'due_at')
  end

  test "responds with 200 when the user has to-dos and the sort_by is set to 'completed_at'" do
    user = users(:john_doe)

    get_and_assert_todos_order(user, column_name: 'completed_at')
  end

  test "responds with 200 when the user has to-dos and the sort_by is set to 'created_at'" do
    user = users(:john_doe)

    get_and_assert_todos_order(user, column_name: 'created_at')
  end

  test "responds with 200 when the user has to-dos and the sort_by is set to 'updated_at'" do
    user = users(:john_doe)

    get_and_assert_todos_order(user, column_name: 'updated_at')
  end

  test "responds with 200 when the user has to-dos and receive the status and sort_by params" do
    user = users(:john_doe)

    get_todos(user, params: { status: 'completed', sort_by: 'title' })

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_order(user.todos.completed, json, title: :desc)

    assert_equal(2, json["todos"].size)
  end
end
