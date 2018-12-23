# frozen_string_literal: true

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
      render(json: { error: "SecureToken invalid ou missing" }, status: :forbidden) if @user.nil?
    end

    def require_admin_authentication!
      load_user
      if @user.nil?
        render(json: { error: "SecureToken invalid ou missing" }, status: :forbidden)
      elsif !@user.is_admin?
        render(json: { error: "Forbidden" }, status: :forbidden)
      end
    end

    def load_user
      @user = SecureToken.active.find_by(token: request.headers["X-Secure-Token"])&.user
      @user = nil if @user && !@user.active
    end

    def base64_to_image(text)
      hash = {}
      if text.start_with? "data:image/jpeg"
        hash[:filename] = "cover.jpg"
        hash[:type] = "image/jpeg"
      elsif texto.start_with? "data:image/png"
        hash[:filename] = "cover.jpg"
        hash[:type] = "image/png"
      else
        raise "Invalid image data"
      end
      tempfile = Tempfile.new("test_temp")
      tempfile.binmode
      tempfile.write(Base64.decode64 text.split(",")[1])
      tempfile.close
      hash[:tempfile] = tempfile
      ActionDispatch::Http::UploadedFile.new hash
    end
  end
end
