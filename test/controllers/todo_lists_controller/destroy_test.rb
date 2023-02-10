require 'test_helper'

class TodoListsControllerDestroyTest < ActionDispatch::IntegrationTest
  concerning :Helpers do
    included do
      include TodoListAssertions::JSON
      include TodoListAssertions::Response
    end

    def destroy_todo_list(id:, user: nil)
      delete(todo_list_url(id: id), headers: AuthenticationHeader.from(user))
    end
  end

  test "responds with 401 when user token is invalid" do
    # Act
    destroy_todo_list(id: 1)

    # Assert
    assert_response 401
  end

  test "responds with 404 when the todo list cannot be found" do
    # Arrange
    user = users(:without_todos)

    # Act
    destroy_todo_list(user:, id: 1)

    # Assert
    assert_todo_list_not_found(response:, id: '1')
  end

  test "responds with 404 when trying to delete the default todo list" do
    # Arrange
    user = users(:john_doe)

    id = user.default_todo_list.id

    # Act
    destroy_todo_list(user:, id:)

    # Assert
    assert_todo_list_not_found(response:, id:)
  end

  test "responds with 200 after deleting an existing todo list" do
    # Arrange
    todo_list = todo_lists(:john_doe_non_default)

    # Act
    assert_difference(-> { todo_list.user.todo_lists.count }, -1) do
      destroy_todo_list(user: todo_list.user, id: todo_list.id)
    end

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    assert_hash_schema({ "todo_list" => Hash }, json)

    assert_todo_list_json(json["todo_list"])
  end
end
