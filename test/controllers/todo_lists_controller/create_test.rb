require 'test_helper'

class TodoListsControllerCreateTest < ActionDispatch::IntegrationTest
  concerning :Helpers do
    included do
      include TodoListAssertions::JSON
      include TodoListAssertions::Response
    end

    def create_todo_list(user: nil, params: {})
      post(todo_lists_url, params:, headers: AuthenticationHeader.from(user))
    end
  end

  test "responds with 401 when user token is invalid" do
    # Act
    create_todo_list

    # Assert
    assert_response 401
  end

  test "responds with 400 when todo_list params are missing" do
    # Arrange
    user = users(:without_todos)

    # Act
    create_todo_list(user:, params: { title: 'Things to learn' })

    # Assert
    assert_response 400

    assert_equal(
      { "error" => "param is missing or the value is empty: todo_list" },
      JSON.parse(response.body)
    )
  end

  test "responds with 422 when invalid params are received" do
    # Arrange
    user = users(:without_todos)

    # Act
    create_todo_list(user:, params: { todo_list: { title: '' } })

    # Assert
    assert_todo_list_unprocessable_entity(response:, errors: { "title"=>["can't be blank"] })
  end

  test "responds with 201 when valid params are received" do
    # Arrange
    user = users(:without_todos)

    # Act
    create_todo_list(user:, params: { todo_list: { title: 'Things to learn' } })

    # Assert
    assert_response 201

    json = JSON.parse(response.body)

    assert user.todo_lists.where(id: json.dig('todo_list', 'id')).exists?

    assert_hash_schema({ "todo_list" => Hash }, json)

    assert_todo_list_json(json["todo_list"])
  end
end
