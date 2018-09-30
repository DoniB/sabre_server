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
  end
end
