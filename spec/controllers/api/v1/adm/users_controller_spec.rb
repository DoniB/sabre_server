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

end
