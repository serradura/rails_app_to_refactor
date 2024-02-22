# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    form = UserForm.new(user_params)

    if form.save
      render_json(201, user: form.user.as_json(only: [:id, :name, :token]))
    else
      render_json(422, user: form.errors.as_json)
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
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def perform_if_authenticated(&block)
      authenticate_user do
        block.call if block

        render_json(200, user: { email: current_user.email })
      end
    end
end
