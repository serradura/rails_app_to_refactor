require 'test_helper'

class TodosControllerDestroyTest < ActionDispatch::IntegrationTest
  concerning :Helpers do
    included do
      include TodoAssertions::JSON
      include TodoAssertions::Response
      include TodoListAssertions::Response
    end

    def destroy_todo(id:, user: nil, todo_list_id: nil)
      url = todo_list_id ? todo_list_todo_url(todo_list_id:, id:) : todo_url(id:)

      delete(url, headers: AuthenticationHeader.from(user))
    end
  end

  test "responds with 401 when user token is invalid" do
    # Act
    destroy_todo(id: 1)

    # Assert
    assert_response 401
  end

  test "responds with 404 when the todo cannot be found" do
    # Arrange
    user = users(:without_todos)

    # Act
    destroy_todo(user:, id: 1)

    # Assert
    assert_todo_not_found(response:, id: '1')
  end

  test "responds with 404 when the requested to-do does not belong to the user" do
    # Arrange
    todo = todos(:john_doe_incomplete)

    todo_from_another_user = users(:without_todos).default_todo_list.todos.create(title: 'New task')

    # Act
    destroy_todo(user: todo.user, id: todo_from_another_user.id)

    # Assert
    assert_todo_not_found(response:, id: todo_from_another_user.id)
  end

  test "responds with 200 after deleting an existing todo" do
    # Arrange
    todo = todos(:john_doe_incomplete)

    # Act
    assert_difference(-> { todo.user.todos.count }, -1) do
      destroy_todo(user: todo.user, id: todo)
    end

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    assert_hash_schema({ "todo" => Hash }, json)

    assert_todo_json(json["todo"])
  end

  ##
  # Nested resource: /todo_lists/:todo_list_id/todo/:id
  #
  test "responds with 404 when the todo list cannot be found" do
    # Arrange
    user = users(:john_doe)

    todo_list_id = 1

    # Act
    destroy_todo(user:, todo_list_id:, id: 1)

    # Assert
    assert_todo_list_not_found(response:, id: '1')
  end

  test "responds with 404 when the todo list does not belong to the user" do
    # Arrange
    user = users(:john_doe)

    todo_list_id = todo_lists(:without_items).id

    # Act
    destroy_todo(user:, todo_list_id:, id: user.todos.first.id)

    # Assert
    assert_todo_list_not_found(response:, id: todo_list_id)
  end

  test "responds with 200 after deleting a todo item from a specific todo list" do
    # Arrange
    todo = todos(:john_doe_incomplete)

    todo_list_id = todo.todo_list.id

    # Act
    assert_difference(-> { todo.user.todos.count }, -1) do
      destroy_todo(user: todo.user, todo_list_id:, id: todo)
    end

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    assert_hash_schema({ "todo" => Hash }, json)

    assert_todo_json(json["todo"])
  end
end
