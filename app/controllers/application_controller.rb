# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Authenticatable
  include TodoListable
  include Renderable

  rescue_from ActionController::ParameterMissing, with: :show_parameter_missing_error

  protected
    
  def show_parameter_missing_error(exception)
      render_json(400, error: exception.message)
  end
end
