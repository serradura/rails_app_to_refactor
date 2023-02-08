require 'test_helper'

class UsersControllerShowTest < ActionDispatch::IntegrationTest
  test "responds with 401 when the user token is invalid" do
    get user_url

    assert_response 401
  end

  test "responds with 200 when the user token is valid" do
    user = users(:john_doe)

    get user_url, headers: { 'Authorization' => "Bearer token=\"#{user.token}\"" }

    assert_response 200

    assert_equal(
      { "user" => { "email" => "john.doe@example.com" } },
      JSON.parse(response.body)
    )
  end
end
