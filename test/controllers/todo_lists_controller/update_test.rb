require 'test_helper'

class TodoListsControllerUpdateTest < ActionDispatch::IntegrationTest
  concerning :Helpers do
    included do
      include TodoListAssertions::JSON
      include TodoListAssertions::Response
    end

    def update_todo_list(id:, user: nil, params: {})
      put(todo_list_url(id: id), params:, headers: AuthenticationHeader.from(user))
    end
  end

  test "responds with 401 when user token is invalid" do
    # Act
    update_todo_list(id: 1)

    # Assert
    assert_response 401
  end

  test "responds with 400 when to-do list parameters are missing" do
    # Arrange
    todo_list = todo_lists(:john_doe_non_default)

    # Act
    update_todo_list(user: todo_list.user, id: todo_list, params: {})

    # Assert
    assert_response 400

    assert_equal(
      { "error" => "param is missing or the value is empty: todo_list" },
      JSON.parse(response.body)
    )
  end

  test "responds with 404 when to-do list not found" do
    # Arrange
    id = todo_lists(:john_doe_non_default).id

    user = users(:without_todos)

    # Act
    update_todo_list(user:, id: id, params: { title: 'Things to do' })

    # Assert
    assert_todo_list_not_found(response:, id:)
  end

  test "responds with 404 when trying to update the default todo list" do
    # Arrange
    user = users(:john_doe)

    id = user.default_todo_list.id

    # Act
    update_todo_list(user:, id: id, params: { title: 'Things to do' })

    # Assert
    assert_todo_list_not_found(response:, id:)
  end

  test "responds with 422 when invalid parameters are received" do
    # Arrange
    todo_list = todo_lists(:john_doe_non_default)

    # Act
    update_todo_list(user: todo_list.user, id: todo_list, params: { todo_list: { title: '' } })

    # Assert
    assert_todo_list_unprocessable_entity(response:, errors: { "title"=>["can't be blank"] })
  end

  test "responds with 200 when a valid title is received" do
    # Arrange
    todo_list = todo_lists(:john_doe_non_default)

    # Act
    update_todo_list(user: todo_list.user, id: todo_list, params: { todo_list: { title: 'Things to buy' } })

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    todo_list_found = todo_list.user.todo_lists.find(json.dig('todo_list', 'id'))

    assert_equal(todo_list.id, todo_list_found.id)

    assert_equal('Things to buy', todo_list_found.title)

    assert_hash_schema({ "todo_list" => Hash }, json)

    assert_todo_list_json(json["todo_list"], default: false)
  end
end
