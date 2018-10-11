require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with attributes' do
    admin = create(:admin)
    expect(admin).to be_valid
    expect(admin.is_admin?).to be_truthy
  end

  it 'do not create admin by default' do
    user = create(:user)
    expect(user).to be_valid
    expect(user.is_admin?).to_not be_truthy
  end

  it 'has admins scope' do
    4.times { create(:user) }
    expect(User.count).to eq(4)
    expect(User.admins.count).to eq(0)
    3.times { create(:admin) }
    expect(User.count).to eq(7)
    expect(User.admins.count).to eq(3)
  end

end
