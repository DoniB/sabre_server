require 'rails_helper'

RSpec.describe Api::V1::Adm::UsersController, type: :controller do

  describe 'GET api/v1//adm/users#index' do

    it 'should list users to admins' do
      3.times { create(:user) }
      admin = create(:admin)
      token = admin.secure_tokens.create

      request.headers['X-Secure-Token'] = token.token

      get :index
      json = JSON.parse(response.body)

      expect(json['users'].size).to eq(4)
      expect(json['page']['current']).to eq(0)
      expect(json['page']['total']).to eq(1)
      expect(json['users'][0]['id']).to eq(admin.id)
      expect(response.status).to eq(200)
    end

    it 'should not list users to non admin' do
      3.times { create(:user) }
      user = create(:user)
      token = user.secure_tokens.create

      request.headers['X-Secure-Token'] = token.token

      get :index
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Forbidden')
      expect(json['users']).to be_nil
      expect(response.status).to eq(403)
    end

    it 'should not list users to visitors' do
      3.times { create(:user) }

      get :index
      json = JSON.parse(response.body)
      expect(json['error']).to eq('SecureToken invalid ou missing')
      expect(json['users']).to be_nil
      expect(response.status).to eq(403)
    end

  end

  describe 'POST api/v1//adm/users#create' do

    it 'should create a user' do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers['X-Secure-Token'] = token.token

      expect(User.count).to eq(1)

      attributes = build(:user).attributes
      attributes['password'] = '123456'

      post :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json['error']).to be_nil
      expect(json['id']).to_not eq(admin.id)
      user = User.first
      expect(json['id']).to eq(user.id)
      expect(json['username']).to eq(user.username)
      expect(json['email']).to eq(user.email)
      expect(json['is_admin']).to be_falsey
      expect(response.status).to eq(201)
    end

    it 'should create a admin' do
      admin = create(:admin)
      token = admin.secure_tokens.create
      request.headers['X-Secure-Token'] = token.token

      expect(User.count).to eq(1)

      attributes = build(:admin).attributes
      attributes['password'] = '123456'

      post :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(2)
      expect(json['error']).to be_nil
      expect(json['id']).to_not eq(admin.id)
      user = User.first
      expect(json['id']).to eq(user.id)
      expect(json['username']).to eq(user.username)
      expect(json['email']).to eq(user.email)
      expect(json['is_admin']).to be_truthy
      expect(response.status).to eq(201)
    end

    it 'should not create a user as a normal user' do
      admin = create(:user)
      token = admin.secure_tokens.create
      request.headers['X-Secure-Token'] = token.token

      expect(User.count).to eq(1)

      attributes = build(:user).attributes
      attributes['password'] = '123456'

      post :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(1)
      expect(json['error']).to eq('Forbidden')
      expect(json['id']).to be_nil
      expect(json['username']).to be_nil
      expect(json['email']).to be_nil
      expect(response.status).to eq(403)
    end

    it 'should not create a user as a visitor' do
      expect(User.count).to eq(0)

      attributes = build(:user).attributes
      attributes['password'] = '123456'

      post :create, params: attributes
      json = JSON.parse(response.body)
      expect(User.count).to eq(0)
      expect(json['error']).to_not be_nil
      expect(json['id']).to be_nil
      expect(json['username']).to be_nil
      expect(json['email']).to be_nil
      expect(response.status).to eq(403)
    end

  end

end
