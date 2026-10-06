# frozen_string_literal: true

class User < ApplicationRecord
  # has_secure_password

  # move validations to model, debloat controller
  # password = user_params[:password].to_s.strip
  # password_confirmation = user_params[:password_confirmation].to_s.strip

  # errors = {}
  # errors[:password] = ["can't be blank"] if password.blank?
  # errors[:password_confirmation] = ["can't be blank"] if password_confirmation.blank?

  # if errors.present?
  #   render_json(422, user: errors)
  # else
  #   if password != password_confirmation
  #     render_json(422, user: { password_confirmation: ["doesn't match password"] })
  #   else
  # end

  has_many :todo_lists, dependent: :destroy, inverse_of: :user
  has_many :todos, through: :todo_lists

  has_one :default_todo_list, ->(user) { user.todo_lists.default }, class_name: 'TodoList'

  validates :name, presence: true
  validates :email, presence: true, format: URI::MailTo::EMAIL_REGEXP, uniqueness: true
  validates :token, presence: true, length: { is: 36 }, uniqueness: true
  validates :password_digest, presence: true, length: { is: 64 }

  after_create :create_default_todo_list
  after_commit :send_welcome_email, on: :create

  private

    def create_default_todo_list
      todo_lists.create!(title: 'Default', default: true)
    end

    def send_welcome_email
      UserMailer.with(user: self).welcome.deliver_later
    end
end
