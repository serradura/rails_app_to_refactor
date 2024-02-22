# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :todo_lists, dependent: :destroy, inverse_of: :user
  has_many :todos, through: :todo_lists

  has_one :default_todo_list, -> { default }, class_name: 'TodoList'

  validates :name, presence: true
  validates :email, presence: true, format: URI::MailTo::EMAIL_REGEXP, uniqueness: true
  validates :token, presence: true, length: { is: 36 }, uniqueness: true
end
