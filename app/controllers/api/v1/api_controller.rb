module Api::V1
  class ApiController < ApplicationController
    # Global Methods


  protected
    def user_hidden_fields
      [:password,
       :password_confirmation,
       :password_digest,
       :id]
    end

    def require_authentication!
      load_user
      render(json: {error: 'SecureToken invalid ou missing'}, status: :forbidden) if @user.nil?
    end

    def load_user
      @user = SecureToken.find_by(token: request.headers['X-Secure-Token'])&.user
    end

  end
end
