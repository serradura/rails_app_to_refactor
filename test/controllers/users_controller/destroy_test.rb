require 'test_helper'

class UsersControllerDestroyTest < ActionDispatch::IntegrationTest
  test "responds with 401 when the user token is invalid" do
    delete user_url

    assert_response 401
  end

  test "responds with 200 when the user token is valid" do
    user = users(:john_doe)

    assert user.todos.any?

    delete user_url, headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" }

    assert_response 200

    assert_equal(
      { "user" => { "email" => "john.doe@example.com" } },
      JSON.parse(response.body)
    )

    refute user.todos.any?
  end
end
