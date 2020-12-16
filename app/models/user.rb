# frozen_string_literal: true

class User < ApplicationRecord
  has_many :todos

  with_options presence: true do
    validates :name
    validates :token, length: { is: 36 }, uniqueness: true
    validates :password_digest, length: { is: 64 }
  end

  after_commit :send_welcome_email

  private

    def send_welcome_email
      UserMailer.with(user: self).welcome.deliver_later
    end
end
