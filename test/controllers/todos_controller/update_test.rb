require 'test_helper'

class TodosControllerUpdateTest < ActionDispatch::IntegrationTest
  concerning :Helpers do
    included do
      include TodoAssertions::JSON
      include TodoAssertions::Response
      include TodoListAssertions::Response
    end

    def update_todo(id:, todo_list_id: nil, user: nil, params: {})
      url = todo_list_id ? todo_list_todo_url(todo_list_id:, id:) : todo_url(id:)

      put(url, params: params, headers: AuthenticationHeader.from(user))
    end
  end

  test "responds with 401 when user token is invalid" do
    # Act
    update_todo(id: 1)

    # Assert
    assert_response 401
  end

  test "responds with 400 when to-do parameters are missing" do
    # Arrange
    todo = todos(:john_doe_incomplete)

    # Act
    update_todo(user: todo.user, id: todo, params: { title: 'Buy coffee' })

    # Assert
    assert_response 400

    assert_todo_bad_request(response:)
  end

  test "responds with 404 when to-do not found" do
    # Arrange
    user = users(:without_todos)

    # Act
    update_todo(user: user, id: 1, params: { title: 'Buy coffee' })

    # Assert
    assert_todo_not_found(response:, id: '1')
  end

  test "responds with 404 when the requested to-do does not belong to the user" do
    # Arrange
    todo = todos(:john_doe_incomplete)

    todo_from_another_user = users(:without_todos).default_todo_list.todos.create(title: 'New task')

    # Act
    update_todo(user: todo.user, id: todo_from_another_user.id, params: { todo: { title: 'Buy coffee' } })

    # Assert
    assert_todo_not_found(response:, id: todo_from_another_user.id)
  end

  test "responds with 422 when invalid parameters are received" do
    # Arrange
    todo = todos(:john_doe_incomplete)

    # Act
    update_todo(user: todo.user, id: todo, params: { todo: { title: '' } })

    # Assert
    assert_todo_unprocessable_entity(response:, errors: { "title"=>["can't be blank"] })
  end

  test "responds with 200 when a valid title is received" do
    # Arrange
    todo = todos(:john_doe_incomplete)

    first_title = todo.title
    second_title = 'Buy coffee'

    # Act
    update_todo(user: todo.user, id: todo, params: { todo: { title: second_title } })

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    todo_found = Todo.find(json.dig('todo', 'id'))

    assert_equal(todo.id, todo_found.id)
    assert_equal(second_title, todo_found.title)

    assert_todo_json(json["todo"])

    assert_predicate(json["todo"]["completed_at"], :blank?)
  end

  test "responds with 200 when a valid completed param is received" do
    # Arrange
    todo = todos(:john_doe_incomplete)

    # Act
    update_todo(user: todo.user, id: todo, params: { todo: { completed: true } })

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    todo_found = Todo.find(json.dig('todo', 'id'))

    assert_equal(todo.id, todo_found.id)
    assert_predicate(todo_found, :completed?)

    assert_todo_json(json["todo"])

    assert_predicate(json["todo"]["completed_at"], :present?)
  end

  test "responds with 200 when a valid title and completed params are received" do
    # Arrange
    todo = todos(:john_doe_completed)

    # Act
    update_todo(user: todo.user, id: todo, params: { todo: { title: 'Buy tea', completed: false } })

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    todo_found = Todo.find(json.dig('todo', 'id'))

    assert_equal(todo.id, todo_found.id)
    assert_equal('Buy tea', todo_found.title)
    assert_predicate(todo_found, :incomplete?)

    assert_todo_json(json["todo"])

    assert_equal('Buy tea', json["todo"]["title"])

    assert_predicate(json["todo"]["completed_at"], :blank?)
  end

  ##
  # Nested resource: /todo_lists/:todo_list_id/todo/:id
  #
  test "responds with 404 when the todo list cannot be found" do
    # Arrange
    user = users(:john_doe)

    todo_list_id = 1

    # Act
    update_todo(user:, todo_list_id:, id: 1, params: { todo: { title: 'Buy tea' } })

    # Assert
    assert_todo_list_not_found(response:, id: 1)
  end

  test "responds with 404 when the todo list does not belong to the user" do
    # Arrange
    user = users(:john_doe)

    todo = todos(:john_doe_incomplete)

    todo_list_id = todo_lists(:without_items).id

    # Act
    update_todo(user:, todo_list_id:, id: todo.id, params: { todo: { title: 'Buy tea' } })

    # Assert
    assert_todo_list_not_found(response:, id: todo_list_id)
  end

  test "responds with 200 after updating a todo item from a specific todo list" do
    # Arrange
    todo = todos(:john_doe_incomplete)

    todo_list_id = todo.todo_list.id

    previous_title = todo.title

    # Act
    update_todo(user: todo.user, todo_list_id:, id: todo, params: { todo: { title: 'Buy tea', completed: false } })

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    todo_found = Todo.find(json.dig('todo', 'id'))

    assert_equal(todo.id, todo_found.id)
    assert_predicate(todo_found, :incomplete?)

    refute_equal(previous_title, todo_found.title)
    assert_equal('Buy tea', todo_found.title)

    assert_todo_json(json["todo"])

    assert_predicate(json["todo"]["completed_at"], :blank?)
  end
end
