require 'test_helper'

class TodoListsControllerShowTest < ActionDispatch::IntegrationTest
  concerning :Helpers do
    included do
      include TodoListAssertions::JSON
      include TodoListAssertions::Response
    end

    def get_todo_list(id:, user: nil)
      get(todo_list_url(id: id), headers: AuthenticationHeader.from(user))
    end
  end

  test "responds with 401 when user token is invalid" do
    # Act
    get_todo_list(id: 1)

    # Assert
    assert_response 401
  end

  test "responds with 404 when the todo list cannot be found" do
    # Arrange
    id = todo_lists(:john_doe_non_default).id

    user = users(:without_todos)

    # Act
    get_todo_list(user:, id:)

    # Assert
    assert_todo_list_not_found(response:, id:)
  end

  test "responds with 200 after finding the todo list" do
    # Arrange
    todo_list = todo_lists(:john_doe_default)

    # Act
    get_todo_list(user: todo_list.user, id: todo_list.id)

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    assert_equal(todo_list.id, json.dig("todo_list", "id"))

    assert_hash_schema({ "todo_list" => Hash }, json)

    assert_todo_list_json(json["todo_list"], default: true)
  end
end
