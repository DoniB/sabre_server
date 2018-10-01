require 'rails_helper'

RSpec.describe SecureToken, type: :model do
  it 'has valid factory' do
    expect(create(:secure_token)).to be_valid
  end

  it 'do not duplicate token' do
    token = create(:secure_token)
    expect(token.dup).to_not be_valid
  end

  it 'auto fill token' do
    token = build(:secure_token)
    expect(token).to be_valid
    token.token = nil
    expect(token).to be_valid
    expect(token.token).to_not be_nil
  end

  it 'has an user' do
    token = create(:secure_token)
    expect(token.user).to_not be_nil
    expect(token.user).to be_a(User)
  end

  it 'has an active scope' do
    create(:secure_token)
    token = create(:secure_token, expires: 1.minute.ago)
    expect(SecureToken.active.count).to eq(1)
    expect(SecureToken.active.find_by token: token.token).to be_nil
  end

end
