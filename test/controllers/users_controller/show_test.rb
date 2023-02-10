require 'test_helper'

class UsersControllerShowTest < ActionDispatch::IntegrationTest
  test "responds with 401 when the user token is invalid" do
    # Act
    get user_url

    # Assert
    assert_response 401
  end

  test "responds with 200 when the user token is valid" do
    # Arrange
    user = users(:john_doe)

    # Act
    get user_url, headers: AuthenticationHeader.from(user)

    # Assert
    assert_response 200

    assert_equal(
      { "user" => { "email" => "john.doe@example.com" } },
      JSON.parse(response.body)
    )
  end
end
