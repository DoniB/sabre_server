# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Adm::UsersController, type: :controller do
  describe "GET api/v1//adm/users#index" do
    it "should list users to admins" do
      3.times { create(:user) }
      admin = create(:admin)
      token = admin.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      get :index
      json = JSON.parse(response.body)

      expect(json["users"].size).to eq(4)
      expect(json["page"]["current"]).to eq(0)
      expect(json["page"]["total"]).to eq(1)
      expect(json["users"][0]["id"]).to eq(admin.id)
      expect(response.status).to eq(200)
    end

    it "should paginate users" do
      30.times { create(:user) }
      admin = create(:admin)
      token = admin.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      get :index
      json = JSON.parse(response.body)

      expect(json["users"].size).to eq(30)
      expect(json["page"]["current"]).to eq(0)
      expect(json["page"]["total"]).to eq(2)
      expect(json["users"][0]["id"]).to eq(admin.id)
      expect(response.status).to eq(200)
    end

    it "should search users" do
      3.times { create(:user) }
      admin = create(:admin)
      token = admin.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      user = create(:user, username: "usuario")

      get :index
      json = JSON.parse(response.body)

      expect(json["users"].size).to eq(5)
      expect(json["page"]["current"]).to eq(0)
      expect(json["page"]["total"]).to eq(1)
      expect(json["users"][0]["id"]).to eq(user.id)
      expect(json["users"][1]["id"]).to eq(admin.id)
      expect(response.status).to eq(200)

      get :index, params: { q: "usuarios" }
      json = JSON.parse(response.body)

      expect(json["users"].size).to eq(1)
      expect(json["page"]["current"]).to eq(0)
      expect(json["page"]["total"]).to eq(1)
      expect(json["users"][0]["id"]).to eq(user.id)
      expect(response.status).to eq(200)
    end

    it "should paginate search for users" do
      31.times { create(:user) }
      admin = create(:admin)
      token = admin.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      31.times { create(:user, username: "usuario") }

      get :index, params: { q: "usuarios" }
      json = JSON.parse(response.body)

      expect(json["users"].size).to eq(30)
      expect(json["page"]["current"]).to eq(0)
      expect(json["page"]["total"]).to eq(2)
      expect(response.status).to eq(200)
    end

    it "should not list users to non admin" do
      3.times { create(:user) }
      user = create(:user)
      token = user.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      get :index
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Forbidden")
      expect(json["users"]).to be_nil
      expect(response.status).to eq(403)
    end

    it "should not list users to visitors" do
      3.times { create(:user) }

      get :index
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("SecureToken invalid ou missing")
      expect(json["users"]).to be_nil
      expect(response.status).to eq(403)
    end
  end

  describe "GET api/v1//adm/users#show" do
    it "should list users to admins" do
      create(:user)
      admin = create(:admin)
      user = create(:user)
      create(:user)
      token = admin.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      get :show, params: { id: user.id }
      json = JSON.parse(response.body)

      expect(User.count).to eq(4)
      expect(json["username"]).to eq(user.username)
      expect(json["email"]).to eq(user.email)
      expect(json["id"]).to eq(user.id)
      expect(json["active"]).to be_truthy
      expect(response.status).to eq(200)
    end

    it "should not list users to non admins" do
      create(:user)
      admin = create(:user)
      user = create(:user)
      create(:user)
      token = admin.secure_tokens.create

      request.headers["X-Secure-Token"] = token.token

      get :show, params: { id: user.id }
      json = JSON.parse(response.body)

      expect(User.count).to eq(4)
      expect(json["username"]).to be_nil
      expect(json["email"]).to be_nil
      expect(json["id"]).to be_nil
      expect(response.status).to eq(403)
    end

    it "should not list users visitors" do
      create(:user)
      user = create(:user)
      create(:user)

      get :show, params: { id: user.id }
      json = JSON.parse(response.body)

      expect(User.count).to eq(3)
      expect(json["username"]).to be_nil
      expect(json["email"]).to be_nil
      expect(json["id"]).to be_nil
      expect(response.status).to eq(403)
    end
  end

  describe "POST api/v1//adm/users#create" do
    it "should create an user" do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(User.count).to eq(1)

      attributes = build(:user).attributes
      attributes["password"] = "123456"

      post :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json["error"]).to be_nil
      expect(json["id"]).to_not eq(admin.id)
      user = User.first
      expect(json["id"]).to eq(user.id)
      expect(json["username"]).to eq(user.username)
      expect(json["email"]).to eq(user.email)
      expect(json["is_admin"]).to be_falsey
      expect(json["active"]).to be_truthy
      expect(response.status).to eq(201)
    end

    it "should create an inactive user" do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(User.count).to eq(1)

      attributes = build(:user, active: false).attributes
      attributes["password"] = "123456"

      post :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json["error"]).to be_nil
      expect(json["id"]).to_not eq(admin.id)
      user = User.first
      expect(json["id"]).to eq(user.id)
      expect(json["username"]).to eq(user.username)
      expect(json["email"]).to eq(user.email)
      expect(json["is_admin"]).to be_falsey
      expect(json["active"]).to be_falsey
      expect(response.status).to eq(201)
    end

    it "should create an admin" do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(User.count).to eq(1)

      attributes = build(:admin).attributes
      attributes["password"] = "123456"

      post :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json["error"]).to be_nil
      expect(json["id"]).to_not eq(admin.id)
      user = User.first
      expect(json["id"]).to eq(user.id)
      expect(json["username"]).to eq(user.username)
      expect(json["email"]).to eq(user.email)
      expect(json["is_admin"]).to be_truthy
      expect(json["active"]).to be_truthy
      expect(response.status).to eq(201)
    end

    it "should create an inactive admin" do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(User.count).to eq(1)

      attributes = build(:admin, active: false).attributes
      attributes["password"] = "123456"

      post :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json["error"]).to be_nil
      expect(json["id"]).to_not eq(admin.id)
      user = User.first
      expect(json["id"]).to eq(user.id)
      expect(json["username"]).to eq(user.username)
      expect(json["email"]).to eq(user.email)
      expect(json["is_admin"]).to be_truthy
      expect(json["active"]).to be_falsey
      expect(response.status).to eq(201)
    end

    it "should not create a user as a normal user" do
      admin = create(:user)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(User.count).to eq(1)

      attributes = build(:user).attributes
      attributes["password"] = "123456"

      post :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(1)
      expect(json["error"]).to eq("Forbidden")
      expect(json["id"]).to be_nil
      expect(json["username"]).to be_nil
      expect(json["email"]).to be_nil
      expect(response.status).to eq(403)
    end

    it "should not create a user as a visitor" do
      expect(User.count).to eq(0)

      attributes = build(:user).attributes
      attributes["password"] = "123456"

      post :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(0)
      expect(json["error"]).to_not be_nil
      expect(json["id"]).to be_nil
      expect(json["username"]).to be_nil
      expect(json["email"]).to be_nil
      expect(response.status).to eq(403)
    end
  end

  describe "PATCH api/v1//adm/users#update" do
    it "should update a user" do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(User.count).to eq(1)

      attributes = create(:user).attributes
      new_username = attributes["username"] + "abc"
      attributes["username"] = attributes["username"] + "abc"

      patch :update, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json["error"]).to be_nil
      expect(json["id"]).to_not eq(admin.id)
      expect(json["id"]).to eq(attributes["id"])
      expect(json["username"]).to eq(new_username)
      expect(json["email"]).to eq(attributes["email"])
      expect(json["is_admin"]).to be_falsey
      expect(response.status).to eq(200)
    end

    it "should change a user to an admin" do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(User.count).to eq(1)

      attributes = create(:user).attributes
      attributes["is_admin"] = true

      expect(User.first.is_admin?).to be_falsey

      patch :update, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json["error"]).to be_nil
      expect(json["id"]).to_not eq(admin.id)
      expect(json["id"]).to eq(attributes["id"])
      expect(json["username"]).to eq(attributes["username"])
      expect(json["email"]).to eq(attributes["email"])
      expect(json["is_admin"]).to be_truthy
      expect(response.status).to eq(200)
    end

    it "should activate an user" do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(User.count).to eq(1)

      attributes = create(:user, active: false).attributes
      attributes["active"] = true

      expect(User.first.active).to be_falsey

      patch :update, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json["error"]).to be_nil
      expect(json["id"]).to_not eq(admin.id)
      expect(json["id"]).to eq(attributes["id"])
      expect(json["username"]).to eq(attributes["username"])
      expect(json["email"]).to eq(attributes["email"])
      expect(json["is_admin"]).to be_falsey
      expect(json["active"]).to be_truthy
      expect(response.status).to eq(200)
    end

    it "should deactivate an user" do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(User.count).to eq(1)

      attributes = create(:user).attributes
      attributes["active"] = false

      expect(User.first.active).to be_truthy

      patch :update, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json["error"]).to be_nil
      expect(json["id"]).to_not eq(admin.id)
      expect(json["id"]).to eq(attributes["id"])
      expect(json["username"]).to eq(attributes["username"])
      expect(json["email"]).to eq(attributes["email"])
      expect(json["is_admin"]).to be_falsey
      expect(json["active"]).to be_falsey
      expect(response.status).to eq(200)
    end

    it "should not update a user as a normal user" do
      admin = create(:user)
      token = admin.secure_tokens.create
      request.headers["X-Secure-Token"] = token.token

      expect(User.count).to eq(1)

      attributes = create(:user).attributes
      attributes["is_admin"] = true

      patch :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json["error"]).to eq("Forbidden")
      expect(json["id"]).to be_nil
      expect(json["username"]).to be_nil
      expect(json["email"]).to be_nil
      expect(response.status).to eq(403)
      expect(User.first.is_admin?).to be_falsey
      expect(User.last.is_admin?).to be_falsey
    end

    it "should not update a user as a visitor" do
      expect(User.count).to eq(0)
      attributes = create(:user).attributes
      attributes["is_admin"] = true
      expect(User.count).to eq(1)

      patch :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(1)
      expect(json["id"]).to be_nil
      expect(json["username"]).to be_nil
      expect(json["email"]).to be_nil
      expect(response.status).to eq(403)
      expect(User.first.is_admin?).to be_falsey
    end
  end
end
