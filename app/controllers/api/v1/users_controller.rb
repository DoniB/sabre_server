class Api::V1::UsersController < Api::V1::ApiController

    def create
        user = User.new params.permit(:username,
                                         :email,
                                         :password,
                                         :password_confirmation)

        if user.save
            render json: user, status: :created,
                   except: user_hidden_fields
        else
            render json: { errors: user.errors},
                         status: :unprocessable_entity
        end
    end

end
