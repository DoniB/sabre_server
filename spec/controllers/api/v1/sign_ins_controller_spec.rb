require 'rails_helper'

RSpec.describe Api::V1::SignInsController, type: :controller do

  it 'should return the user info when sign in' do
    user = create(:user, password: 'abc123')
    post :create, params: { email:    user.email,
                            password: 'abc123' }
    json = JSON.parse(response.body)
    expect(json['errors']).to be_nil
    expect(response.status).to eq(201)
    expect(json['username']).to eq(user.username)
    expect(json['email']).to eq(user.email)
  end

  it 'should return a valid user token when sign in' do
    user = create(:user, password: 'abc123')
    post :create, params: { email:    user.email,
                            password: 'abc123' }
    json = JSON.parse(response.body)
    expect(json['token']).to_not be_nil
    expect(json['expires']).to_not be_nil
    expect(SecureToken.find_by token: json['token']).to_not be_nil
  end

  it 'should not return the user sensitive data' do
    user = create(:user, password: 'abc123')
    post :create, params: { email:    user.email,
                            password: 'abc123' }
    json = JSON.parse(response.body)
    expect(json['password']).to be_nil
    expect(json['password_confirmation']).to be_nil
    expect(json['password_digest']).to be_nil
    expect(json['id']).to be_nil
  end

end
