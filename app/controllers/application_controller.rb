# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Authenticatable
  include TodoListable
  include Errorable
  include Renderable

  rescue_from ActionController::ParameterMissing, with: :show_parameter_missing_error
end
