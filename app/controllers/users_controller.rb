# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    # sha256 less secure than bcrypt
    # security improvement: migration, or require password resets
    password_digest = Digest::SHA256.hexdigest(password)

    user = User.new(
      name: user_params[:name],
      email: user_params[:email],
      token: SecureRandom.uuid,
      password_digest: password_digest
    )

    if user.save
      render_json(201, user: user.as_json(only: [:id, :name, :token]))
    else
      render_json(422, user: user.errors.as_json)
    end
  end

  def show
    perform_if_authenticated
  end

  def destroy
    perform_if_authenticated do
      current_user.destroy
    end
  end

  private
    def user_params
      user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def perform_if_authenticated(&block)
      authenticate_user do
        block.call if block

        render_json(200, user: { email: current_user.email })
      end
    end
end
