# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user, only: [:show, :destroy]

  def create
    form = UserForm.new(user_params)

    if form.save
      render_json(:created, user: form.user.as_json(only: [:id, :name, :token]))
    else
      render_json(:unprocessable_entity, user: form.errors.as_json)
    end
  end

  def show
    render_json(:ok, user: { email: current_user.email })
  end

  def destroy
    if current_user.destroy
      render_json(:ok, user: { email: current_user.email })
    else
      render_json(:unprocessable_entity, errors: current_user.errors.as_json)
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
