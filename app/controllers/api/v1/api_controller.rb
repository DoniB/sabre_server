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
      @user = SecureToken.active.eager_load(:user).find_by(token: request.headers["X-Secure-Token"])&.user
      @user = nil if @user && !@user.active
    end

    def base64_to_image(text)
      hash = ApiController.get_image_hash text
      hash[:tempfile] = ApiController.get_temp_file(text.split(",")[1])
      ActionDispatch::Http::UploadedFile.new hash
    end
  end

    def self.get_image_hash(text)
      if text.start_with? "data:image/jpeg"
        { filename: "cover.jpg", type: "image/jpeg" }
      elsif texto.start_with? "data:image/png"
        { filename: "cover.jpg", type: "image/png" }
      else
        raise "Invalid image data"
      end
    end

    def self.get_temp_file(base64_encoded_text)
      tempfile = Tempfile.new("test_temp")
      tempfile.binmode
      tempfile.write(Base64.decode64 base64_encoded_text)
      tempfile.close
      tempfile
    end
end
