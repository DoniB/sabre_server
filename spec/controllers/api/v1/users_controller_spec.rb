# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::UsersController, type: :controller do
  describe "POST api/v1/user#create" do
    it "is valid with attributes" do
      user = build(:user)
      post :create, params: { username: user.username,
                              email:    user.email,
                              password: user.password }
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_nil
      expect(response.status).to eq(201)
      expect(User.find_by email: user.email).to_not be_nil
    end

    it "is not valid without the username" do
      user = build(:user)
      post :create, params: { email:    user.email,
                              password: user.password }
      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(response.status).to eq(422)
      expect(User.find_by email: user.email).to be_nil
    end

    it "is not valid without the email" do
      user = build(:user)
      post :create, params: { username: user.username,
                              password: user.password }
      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(response.status).to eq(422)
      expect(User.find_by email: user.email).to be_nil
    end

    it "is not valid without the password" do
      user = build(:user)
      post :create, params: { username: user.username,
                              email:    user.email }
      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(response.status).to eq(422)
      expect(User.find_by email: user.email).to be_nil
    end

    it "is not valid with invalid email" do
      user = build(:user)

      ["email with space@example.com",
       "emailwithspace@example . com",
       "withoutAt.com",
       "withoutat.com",
       "withou@dot"].each do | email |
        post :create, params: { password: user.password,
                                username: user.username,
                                email:    email }
        json = JSON.parse(response.body)
        expect(json["errors"]).to_not be_nil
        expect(response.status).to eq(422)
        expect(User.find_by email: email).to be_nil
      end
    end

    it "is not valid with password less than 6 characters" do
      user = build(:user, password: "12345")
      post :create, params: { username: user.username,
                              email:    user.email,
                              password: user.password }
      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(response.status).to eq(422)
      expect(User.find_by email: user.email).to be_nil
    end

    it "is not valid with duplicate email" do
      user = create(:user)
      expect(User.find_by email: user.email).to_not be_nil
      post :create, params: { email:    user.email,
                              password: user.password,
                              username: user.username }
      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(response.status).to eq(422)
    end

    it "saves emails with the lower case" do
      user = build(:user, email: "EMAIL@EXAMPLE.COM")
      post :create, params: { username: user.username,
                              email:    user.email,
                              password: user.password }
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_nil
      expect(response.status).to eq(201)
      expect(User.find_by email: user.email).to be_nil
      expect(User.find_by email: user.email.downcase).to_not be_nil
      expect(json["email"]).to eq(user.email.downcase)
    end

    it "is not valid with different password and password_confirmation" do
      password = ("a".."z").to_a.join
      user = build(:user, password: password)
      post :create, params: { username: user.username,
                              email:    user.email,
                              password: user.password,
                              password_confirmation: password.reverse }
      json = JSON.parse(response.body)
      expect(json["errors"]).to_not be_nil
      expect(response.status).to eq(422)
      expect(User.find_by email: user.email).to be_nil
    end

    it "is valid with password equals to password_confirmation" do
      password = ("a".."z").to_a.join
      user = build(:user, password: password)
      post :create, params: { username: user.username,
                              email:    user.email,
                              password: user.password,
                              password_confirmation: password }
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_nil
      expect(response.status).to eq(201)
      expect(User.find_by email: user.email).to_not be_nil
    end

    it "should return the new user attributes" do
      user = build(:user)
      post :create, params: { username: user.username,
                              email:    user.email,
                              password: user.password }
      json = JSON.parse(response.body)
      expect(json["username"]).to eq(user.username)
      expect(json["email"]).to eq(user.email)
      expect(json["created_at"]).to_not be_nil
      expect(json["updated_at"]).to_not be_nil
      expect(response.status).to eq(201)
    end

    it "should not return the new user sensitive data" do
      user = build(:user)
      post :create, params: { username: user.username,
                              email:    user.email,
                              password: user.password,
                              password_confirmation: user.password }
      json = JSON.parse(response.body)
      expect(json["password"]).to be_nil
      expect(json["password_confirmation"]).to be_nil
      expect(json["password_digest"]).to be_nil
      expect(json["id"]).to be_nil
      expect(response.status).to eq(201)
    end

    it "should return a new secure token" do
      user = build(:user)
      post :create, params: { username: user.username,
                              email:    user.email,
                              password: user.password,
                              password_confirmation: user.password }
      json = JSON.parse(response.body)
      expect(json["token"]).to_not be_nil
      expect(json["expires"]).to_not be_nil
      expect(response.status).to eq(201)
    end
  end

  describe "GET api/v1/user#show" do
    it "should return user info and token when valid token" do
      user = create :user
      token = user.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token
      get :show

      json = JSON.parse(response.body)
      expect(json["expires"]).to_not be_nil
      expect(json["token"]).to eq(token.token)
      expect(json["email"]).to eq(user.email)
      expect(json["username"]).to eq(user.username)
      expect(response.status).to eq(200)
    end

    it "should not return user sensitive info when valid token" do
      user = create :user
      token = user.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token
      get :show

      json = JSON.parse(response.body)
      expect(json["password"]).to be_nil
      expect(json["password_confirmation"]).to be_nil
      expect(json["password_digest"]).to be_nil
      expect(json["id"]).to be_nil
      expect(response.status).to eq(200)
    end

    it "should not return user info or token when invalid token" do
      user = create :user
      token = user.secure_tokens.create

      request.headers["X-Secure-Token"] = (token.token + "abc")
      get :show

      json = JSON.parse(response.body)
      expect(json["expires"]).to be_nil
      expect(json["token"]).to_not eq(token.token)
      expect(json["email"]).to_not eq(user.email)
      expect(json["username"]).to_not eq(user.username)
      expect(response.status).to eq(403)
    end

    it "should not return user info or token without token" do
      user = create :user

      get :show

      json = JSON.parse(response.body)
      expect(json["expires"]).to be_nil
      expect(json["token"]).to be_nil
      expect(json["email"]).to_not eq(user.email)
      expect(json["username"]).to_not eq(user.username)
      expect(response.status).to eq(403)
    end

    it "do not create admin by default" do
      user = build(:user)
      post :create, params: { username: user.username,
                              email:    user.email,
                              password: user.password }
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_nil
      expect(response.status).to eq(201)
      expect(json["is_admin"]).to eq(false)
      expect(User.find_by(email: user.email).is_admin?).to_not be_truthy
    end

    it "should return is_admin:true for admin" do
      user = create :admin
      token = user.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token
      get :show

      json = JSON.parse(response.body)
      expect(json["password"]).to be_nil
      expect(json["password_confirmation"]).to be_nil
      expect(json["password_digest"]).to be_nil
      expect(json["id"]).to be_nil
      expect(json["is_admin"]).to eq(true)
      expect(response.status).to eq(200)
    end
  end
end
