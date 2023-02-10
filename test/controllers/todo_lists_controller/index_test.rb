require 'test_helper'

class TodoListsControllerIndexTest < ActionDispatch::IntegrationTest
  concerning :Helpers do
    included do
      include TodoListAssertions::JSON
      include TodoListAssertions::Response
    end

    def get_todo_lists(user: nil, params: {})
      get(todo_lists_url, params:, headers: AuthenticationHeader.from(user))
    end

    def assert_todo_lists_json_schema(json)
      assert_hash_schema({"todo_lists" => Array}, json)

      json["todo_lists"].each { |item| assert_todo_list_json(item, default: item['default']) }
    end

    def assert_todo_lists_json_order(relation, response, **sort_by)
      json = response.is_a?(Hash) ? response : JSON.parse(response.body)

      assert_todo_lists_json_schema(json)

      todo_lists = relation.is_a?(User) ? relation.todo_lists : relation

      assert_equal(
        todo_lists.order(sort_by).map(&:id),
        json['todo_lists'].map { |todo_list| todo_list['id'] },
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
      get_todo_lists(user:, params: { sort_by: })

      assert_response 200

      assert_todo_lists_json_order(user, response, column_name => :desc)

      ##
      # DESC
      #
      get_todo_lists(user:, params: { sort_by:, order: prepare_param.('desc') })

      assert_response 200

      assert_todo_lists_json_order(user, response, column_name => :desc)

      ##
      # ASC
      #
      get_todo_lists(user:, params: { sort_by:, order: prepare_param.('asc') })

      assert_response 200

      assert_todo_lists_json_order(user, response, column_name => :asc)
    end
  end

  test "responds with 401 when the user token is invalid" do
    # Act
    get_todo_lists

    # Assert
    assert_response 401
  end

  test "responds with 200 even when the user only the default to-do lists" do
    # Arrange
    user = users(:without_todos)

    # Act
    get_todo_lists(user:)

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    assert_todo_lists_json_schema(json)

    assert_equal(1, json["todo_lists"].size)
  end

  test "responds with 200 when the user has to-do lists and no filter status is applied" do
    # Arrange
    user = users(:john_doe)

    # Act
    get_todo_lists(user:)

    # Assert
    assert_response 200

    json = JSON.parse(response.body)

    assert_todo_lists_json_schema(json)

    assert_equal(2, json["todo_lists"].size)
  end

  test "responds with 200 when the user has to-do lists and the sort_by is set to 'title'" do
    # Arrange
    user = users(:john_doe)

    # Act & Assert
    get_and_assert_todos_order(user, column_name: 'title')
  end

  test "responds with 200 when the user has to-do lists and the sort_by is set to 'created_at'" do
    # Arrange
    user = users(:john_doe)

    # Act & Assert
    get_and_assert_todos_order(user, column_name: 'created_at')
  end

  test "responds with 200 when the user has to-do lists and the sort_by is set to 'updated_at'" do
    # Arrange
    user = users(:john_doe)

    # Act & Assert
    get_and_assert_todos_order(user, column_name: 'updated_at')
  end
end
