require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = users(:john_doe)

    email = UserMailer.with(user: user).welcome

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal(["from@example.com"], email.from)
    assert_equal(["john.doe@example.com"], email.to)
    assert_equal("Welcome aboard", email.subject)
    assert_equal("Hi John Doe, thanks for signing up...", email.body.to_s)
  end
end
