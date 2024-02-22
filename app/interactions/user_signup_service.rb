class UserSignupService
  attr_reader :user

  def initialize(user_params)
    @user_params = user_params
    @user = User.new(user_params)
  end

  def call
    if @user.save
      create_default_todo_list
      send_welcome_email
      return user
    else
      return false
    end
  end

  private

  def send_welcome_email
    UserMailer.with(user: @user).welcome.deliver_later
  end

  def create_default_todo_list
    @user.todo_lists.create!(title: 'Default', default: true)
  end
end
