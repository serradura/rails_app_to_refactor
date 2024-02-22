class UserForm
    include ActiveModel::Model

    attr_accessor :name, :email, :password, :password_confirmation, :user

    validates :password, presence: true
    validates :password_confirmation, presence: true
    validate :password_confirmation_matches, if: -> { password.present? && password_confirmation.present? }   


    def save
        return false unless valid?

        service = UserSignupService.new(
          name: name,
          email: email,
          token: token,
          password_digest: password_digest
        )
    
        if service.call
          @user = service.user
          true
        else
          errors.merge!(service.user.errors)
          false
        end
    end

    private
    
    def password_digest
        Digest::SHA256.hexdigest(password)
    end

    def token
        SecureRandom.uuid
    end

    def password_confirmation_matches
        errors.add(:password_confirmation, "doesn't match password") if password != password_confirmation
    end
end