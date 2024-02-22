module Errorable
    protected
    
    def show_parameter_missing_error(exception)
        render_json(400, error: exception.message)
    end
end