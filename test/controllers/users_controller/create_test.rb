require 'test_helper'

class UsersControllerCreateTest < ActionDispatch::IntegrationTest
  test "should respond with 400 when the user param is missing" do
    post users_url

    assert_response 400

    assert_equal(
      { "error" => "param is missing or the value is empty: user" },
      JSON.parse(response.body)
    )
  end

  test "should respond with 400 when the user password params are missing" do
    post users_url, params: { user: { password: '' } }

    assert_response 422

    assert_equal(
      {
        "user" => {
          "password" => ["can't be blank"],
          "password_confirmation" => ["can't be blank"]
        }
      },
      JSON.parse(response.body)
    )
  end

  test "should respond with 400 when the user password params are differents" do
    post users_url, params: { user: { password: '123', password_confirmation: '321' } }

    assert_response 422

    assert_equal(
      { "user" => { "password_confirmation" => ["doesn't match password"] } },
      JSON.parse(response.body)
    )
  end

  test "should respond with 422 when the user data is invalid" do
    post users_url, params: { user: { password: '123', password_confirmation: '123', name: '' } }

    assert_response 422

    assert_equal(
      {"user" => {
        "name" => ["can't be blank"],
        "email"=>["can't be blank", "is invalid"]
      }},
      JSON.parse(response.body)
    )
  end

  test "should respond with 201 when creating the user" do
    # == Arrange ==
    user_params = { user: {
      name: 'Serradura',
      email: 'serradura@gmail.com',
      password: '123',
      password_confirmation: '123' } }

    # == Act ==
    assert_difference 'User.count', +1 do
      assert_enqueued_emails 1 do
        post(users_url, params: user_params)
      end
    end

    # == Assert ==
    assert_response 201

    json = JSON.parse(response.body)

    user_id = json.dig("user", "id")

    relation = User.where(id: user_id)

    # FACT: A user will be persisted.
    assert_predicate(relation, :exists?)

    # FACT: The JSON response will have the user's token.
    assert_hash_schema({
      "id" => Integer,
      "name" => "Serradura",
      "token" => RegexpPatterns::UUID
    }, json["user"])

    # FACT: An email will be sent after the user creation.
    job = ActiveJob::Base.queue_adapter.enqueued_jobs.first

    assert_equal("ActionMailer::MailDeliveryJob", job["job_class"])

    assert_equal("UserMailer#welcome", job['arguments'][0..1].join('#'))

    job_user_gid = GlobalID.parse(job['arguments'].last.dig("params", "user", "_aj_globalid"))

    assert_equal(user_id.to_s, job_user_gid.model_id)

    # == Teardown ==
    relation.delete_all
  end
end
