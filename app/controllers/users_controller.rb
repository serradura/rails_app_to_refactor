# frozen_string_literal: true

class UsersController < ApplicationController

  # consider authorization when creating users. RBAC? shared secret?
  def create

    # TODO: use the create_params function
    user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)

    password = user_params[:password].to_s.strip
    password_confirmation = user_params[:password_confirmation].to_s.strip

    # Won't need this once params are required
    errors = {}
    errors[:password] = ["can't be blank"] if password.blank?
    errors[:password_confirmation] = ["can't be blank"] if password_confirmation.blank?

    # can remove this conditional
    if errors.present?
      render_json(422, user: errors)
    else

      # this should be handled in the model
      if password != password_confirmation
        render_json(422, user: { password_confirmation: ["doesn't match password"] })
      else
        # this gets handled in the model
        password_digest = Digest::SHA256.hexdigest(password)

        # this becomes a call with email/password
        # this should be a call to a user service
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

  def create_params
    user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)
    user_params[:password].to_s.strip
    user_params[:password_confirmation].to_s.strip
    user_params
  end

    def perform_if_authenticated(&block)
      authenticate_user do
        block.call if block

        render_json(200, user: { email: current_user.email })
      end
    end
end
