require 'test_helper'

class TodosControllerUncompleteTest < ActionDispatch::IntegrationTest
  concerning :Helpers do
    included do
      include TodoAssertions::JSON
      include TodoAssertions::Response
      include TodoListAssertions::Response
    end

    def incomplete_todo(id:, user: nil, todo_list_id: nil)
      url = todo_list_id ? incomplete_todo_list_todo_url(todo_list_id:, id:) : incomplete_todo_url(id:)

      put(url, headers: AuthenticationHeader.from(user))
    end

    def todo_from_another_user
      @todo_from_another_user ||=
        users(:without_todos).default_todo_list.todos.create(title: 'New todo')
    end
  end

  test "responds with 401 when user token is invalid" do
    # Act
    incomplete_todo(id: 1)

    # Assert
    assert_response 401
  end

  test "responds with 404 when the todo cannot be found" do
    # Arrange
    user = users(:without_todos)

    # Act
    incomplete_todo(user:, id: 1)

    # Assert
    assert_todo_not_found(response:, id: '1')
  end

  test "responds with 404 when the requested to-do does not belong to the user" do
    # Arrange
    todo = todos(:john_doe_completed)

    # Act
    incomplete_todo(user: todo.user, id: todo_from_another_user.id)

    # Assert
    assert_todo_not_found(response:, id: todo_from_another_user.id)
  end

  test "responds with 200 after marking an existing todo as incomplete" do
    # Arrange
    todo = todos(:john_doe_completed)

    # Act
    incomplete_todo(user: todo.user, id: todo.id)

    # Assert
    assert_response 200

    todo.reload

    assert_predicate(todo, :incomplete?)

    json = JSON.parse(response.body)

    assert_hash_schema({ "todo" => Hash }, json)

    assert_todo_json(json["todo"])
  end

  ##
  # Nested resource: /todo_lists/:todo_list_id/todos/:id/incomplete
  #
  test "responds with 404 when the todo list cannot be found" do
    # Arrange
    user = users(:john_doe)

    # Act
    incomplete_todo(user:, id: user.todos.first, todo_list_id: 1)

    # Assert
    assert_todo_list_not_found(response:, id: '1')
  end

  test "responds with 404 when the todo is not found in the specified todo list" do
    # Arrange
    todo = todos(:john_doe_completed)

    todo_list_id = todo_lists(:john_doe_non_default).id

    # Act
    incomplete_todo(user: todo.user, todo_list_id:, id: todo)

    # Assert
    assert_todo_not_found(response:, id: todo.id)
  end

  test "responds with 200 after marking an existing todo as incomplete from a specific todo list" do
    # Arrange
    todo = todos(:john_doe_completed)

    todo_list_id = todo.todo_list.id

    # Act
    incomplete_todo(user: todo.user, todo_list_id:, id: todo.id)

    # Assert
    assert_response 200

    todo.reload

    assert_predicate(todo, :incomplete?)

    json = JSON.parse(response.body)

    assert_equal(todo_list_id, todo.todo_list_id)

    assert_hash_schema({ "todo" => Hash }, json)

    assert_todo_json(json["todo"])
  end
end
