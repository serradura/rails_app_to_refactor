require 'test_helper'

class UsersControllerDestroyTest < ActionDispatch::IntegrationTest
  test "responds with 401 when the user token is invalid" do
    # Act
    delete user_url

    # Assert
    assert_response 401
  end

  test "responds with 200 when the user token is valid" do
    # Arrange
    user = users(:john_doe)

    assert user.todos.any?

    # Act
    delete user_url, headers: AuthenticationHeader.from(user)

    # Assert
    assert_response 200

    assert_equal(
      { "user" => { "email" => "john.doe@example.com" } },
      JSON.parse(response.body)
    )

    refute user.todos.any?
  end
end
