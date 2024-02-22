module ErrorHandleable
    extend ActiveSupport::Concern
  
    included do
      rescue_from ActionController::ParameterMissing, with: :show_parameter_missing_error
    end
  
    protected
  
    def show_parameter_missing_error(exception)
      render_json(400, error: exception.message)
    end
  end