require 'test_helper'

class TodosControllerCreateTest < ActionDispatch::IntegrationTest
  concerning :Helpers do
    included do
      include TodoAssertions::JSON
      include TodoAssertions::Response
      include TodoListAssertions::Response
    end

    def create_todo(user: nil, params: {}, todo_list_id: nil)
      url = todo_list_id ? todo_list_todos_url(todo_list_id) : todos_url

      post(url, params:, headers: AuthenticationHeader.from(user))
    end
  end

  test "responds with 401 when user token is invalid" do
    # Act
    create_todo

    # Assert
    assert_response 401
  end

  test "responds with 400 when todo params are missing" do
    # Arrange
    user = users(:without_todos)

    # Act
    create_todo(user:, params: { title: 'Buy coffee' })

    # Assert
    assert_response 400

    assert_todo_bad_request(response:)
  end

  test "responds with 422 when invalid params are received" do
    # Arrange
    user = users(:without_todos)

    # Act
    create_todo(user:, params: { todo: { title: '' } })

    # Assert
    assert_todo_unprocessable_entity(response:, errors: { "title"=>["can't be blank"] })
  end

  test "responds with 201 when valid params are received" do
    # Arrange
    user = users(:without_todos)

    # Act
    create_todo(user:, params: { todo: { title: 'Buy coffee' } })

    # Assert
    assert_response 201

    json = JSON.parse(response.body)

    relation = Todo.where(id: json.dig('todo', 'id'))

    assert_predicate(relation, :exists?)

    assert_hash_schema({ "todo" => Hash }, json)

    assert_todo_json(json["todo"])
  end

  ##
  # Nested resource: /todo_lists/:todo_list_id/todos
  #
  test "responds with 404 when the todo list cannot be found" do
    # Arrange
    user = users(:john_doe)

    todo_list_id = 1

    # Act
    create_todo(user:, todo_list_id:, params: { todo: { title: 'Buy coffee' } })

    # Assert
    assert_todo_list_not_found(response:, id: '1')
  end

  test "responds with 404 when the todo list does not belong to the user" do
    # Arrange
    user = users(:john_doe)

    todo_list_id = todo_lists(:without_items).id

    # Act
    create_todo(user:, todo_list_id: , params: { todo: { title: 'Buy coffee' } })

    # Assert
    assert_todo_list_not_found(response:, id: todo_list_id)
  end

  test "responds with 201 when valid params are received for create a todo in a todo list" do
    # Arrange
    user = users(:john_doe)

    todo_list_id = todo_lists(:john_doe_non_default).id

    # Act
    create_todo(user:, todo_list_id:, params: { todo: { title: 'Buy coffee' } })

    # Assert
    assert_response 201

    json = JSON.parse(response.body)

    todo = Todo.find(json.dig('todo', 'id'))

    assert_equal(todo_list_id, todo.todo_list_id)

    assert_hash_schema({ "todo" => Hash }, json)

    assert_todo_json(json["todo"])
  end
end
