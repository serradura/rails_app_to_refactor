require 'test_helper'

class TodosControllerIndexTest < ActionDispatch::IntegrationTest
  concerning :Helpers do
    included do
      include TodoAssertions::JSON
      include TodoAssertions::Response
      include TodoListAssertions::Response
    end

    def get_todos(user: nil, todo_list_id: nil, params: {})
      url = todo_list_id ? todo_list_todos_url(todo_list_id) : todos_url

      get(url, params:, headers: AuthenticationHeader.from(user))
    end

    def assert_todos_json_schema(json)
      assert_hash_schema({"todos" => Array}, json)

      json["todos"].each { |item| assert_todo_json(item) }
    end

    def assert_todos_json_order(relation, response, todo_list_id, **sort_by)
      json = response.is_a?(Hash) ? response : JSON.parse(response.body)

      assert_todos_json_schema(json)

      todos = relation.is_a?(User) ? relation.todos : relation
      todos = todos.where(todo_list_id: todo_list_id) if todo_list_id

      assert_equal(
        todos.order(sort_by).map(&:id),
        json['todos'].map { |todo| todo['id'] },
        sort_by.inspect
      )
    end

    def get_and_assert_todos_order(user, column_name:, todo_list_id: nil)
      prepare_param = ->(str) do
        [str.capitalize, str.upcase, str].sample.then { [" #{_1}", " #{_1} ", " #{_1} "].sample }
      end

      sort_by = prepare_param.(column_name)

      ##
      # DEFAULT
      #
      get_todos(user:, todo_list_id:, params: { sort_by: })

      assert_response 200

      assert_todos_json_order(user, response, todo_list_id, column_name => :desc)

      ##
      # DESC
      #
      get_todos(user:, todo_list_id:, params: { sort_by:, order: prepare_param.('desc') })

      assert_response 200

      assert_todos_json_order(user, response, todo_list_id, column_name => :desc)

      ##
      # ASC
      #
      get_todos(user:, todo_list_id:, params: { sort_by:, order: prepare_param.('asc') })

      assert_response 200

      assert_todos_json_order(user, response, todo_list_id, column_name => :asc)
    end
  end

  test "responds with 401 when the user token is invalid" do
    get_todos

    assert_response 401
  end

  test "responds with 200 even when the user has no to-dos" do
    user = users(:without_todos)

    get_todos(user:, params: {})

    assert_response 200

    assert_equal(
      { "todos" => [] },
      JSON.parse(response.body)
    )
  end

  test "responds with 200 when the user has to-dos and no filter status is applied" do
    user = users(:john_doe)

    get_todos(user:, params: {})

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(4, json["todos"].size)
  end

  test "responds with 200 when the user has to-dos and the filter status is set to 'incomplete'" do
    user = users(:john_doe)

    get_todos(user:, params: { status: 'incomplete' })

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(2, json["todos"].size)
  end

  test "responds with 200 when the user has to-dos and the filter status is set to 'completed'" do
    user = users(:john_doe)

    get_todos(user:, params: { status: 'completed' })

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(2, json["todos"].size)

    assert(json["todos"].all? { |todo| todo['completed_at'].present? })
  end

  test "responds with 200 when the user has to-dos and the filter status is set to 'overdue'" do
    user = users(:john_doe)

    get_todos(user:, params: { status: 'overdue' })

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

  test "responds with 200 when the user has to-dos and the sort_by is set to 'todo_list_id'" do
    user = users(:john_doe)

    user.todo_lists.non_default.first.todos.create(title: 'New todo')

    get_and_assert_todos_order(user, column_name: 'todo_list_id')
  end

  test "responds with 200 when the user has to-dos and receive the status and sort_by params" do
    user = users(:john_doe)

    get_todos(user:, params: { status: 'completed', sort_by: 'title' })

    assert_response 200

    json = JSON.parse(response.body)

    todo_list_id = nil

    assert_todos_json_order(user.todos.completed, json, todo_list_id, title: :desc)

    assert_equal(2, json["todos"].size)
  end

  ##
  # Nested resource: /todo_lists/:todo_list_id/todos
  #
  test "responds with 404 when the todo list cannot be found" do
    user = users(:john_doe)

    get_todos(user:, todo_list_id: 1)

    assert_todo_list_not_found(response:, id: '1')
  end

  test "responds with 200 when the user requests a specific todo list" do
    user = users(:john_doe)

    todos = user.todo_lists.non_default.first.todos

    todo = todos.create(title: 'New todo')

    get_todos(user:, todo_list_id: todo.todo_list_id)

    assert_response 200

    json = JSON.parse(response.body)

    assert_todos_json_schema(json)

    assert_equal(1, json["todos"].size)
  end

  test "responds with 200 when the user requests a specific todo list and uses some filtering" do
    todo_list = todo_lists(:john_doe_non_default)

    todo_list.todos.create(title: 'New todo 2')
    todo_list.todos.create(title: 'New todo 1').tap(&:complete!)
    todo_list.todos.create(title: 'New todo 3')

    user = todo_list.user

    ##
    # Check the sorting
    #
    get_and_assert_todos_order(user, todo_list_id: todo_list.id, column_name: 'title')

    ##
    # Check the filtering by status
    #
    get_todos(user:, todo_list_id: todo_list.id, params: { status: 'completed' })

    assert_response 200

    json2 = JSON.parse(response.body)

    assert_equal(1, json2["todos"].size)
  end
end
