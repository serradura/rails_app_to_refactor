# frozen_string_literal: true

module AuthenticationHeader
  def self.from(user)
    user ? { 'Authorization' => "Bearer token=\"#{user.token}\"" } : {}
  end
end
