class UserForm
    include ActiveModel::Model

    attr_accessor :name, :email, :password, :password_confirmation

    validates :password, presence: true
    validates :password_confirmation, presence: true
    validate :password_confirmation_matches, if: -> { password.present? && password_confirmation.present? }   


    def save
        return false unless valid?

        password_digest = Digest::SHA256.hexdigest(password)
        user = User.new(
          name: name,
          email: email,
          token: SecureRandom.uuid,
          password_digest: password_digest
        )
    
        if user.save
          @user = user
          true
        else
          errors.merge!(user.errors)
          false
        end
    end

    def user
        @user
    end

    private
    
    def password_confirmation_matches
        def password_confirmation_matches
            errors.add(:password_confirmation, "doesn't match password") if password != password_confirmation
        end
    end
end