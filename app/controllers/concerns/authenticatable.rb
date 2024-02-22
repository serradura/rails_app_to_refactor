module Authenticatable
    protected

    def authenticate_user(&block)
        return block&.call if current_user
  
        head :unauthorized
    end

    def current_user
        @current_user ||= authenticate_with_http_token do |token|
            User.find_by(token: token)
        end
    end
end