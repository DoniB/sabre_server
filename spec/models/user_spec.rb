require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with attributes' do
    expect(create(:user)).to be_valid
  end

  it 'is not valid without the username' do
    user = build(:user, username: nil)
    expect(user).to_not be_valid
  end

  it 'is not valid without the email' do
    user = build(:user, email: nil)
    expect(user).to_not be_valid
  end

  it 'is not valid without the password' do
    user = build(:user, password: nil)
    expect(user).to_not be_valid
  end

  it 'is not valid with invalid email' do
    user = build(:user, email: 'email with space@example.com')
    expect(user).to_not be_valid
    user.email = 'emailwithspace@example . com'
    expect(user).to_not be_valid
    user.email = 'withoutAt.com'
    expect(user).to_not be_valid
    user.email = 'withoutat.com'
    expect(user).to_not be_valid
    user.email = 'withou@dot'
    expect(user).to_not be_valid
  end

  it 'is not valid with password less than 6 characters' do
    user = build(:user, password: '12345')
    expect(user).to_not be_valid
  end

  it 'is not valid with duplicate email' do
    user = create(:user).dup
    expect(user).to_not be_valid
  end

  it 'saves emails with the lower case' do
    email = 'EMAIL@EXAMPLE.COM'
    user = create(:user, email: email)
    expect(user.email).to eq(email.downcase)
  end

  it 'is not valid with different password and password_confirmation' do
    password = ('a'..'z').to_a.join
    user = build(:user, password: password)
    user.password_confirmation = password.reverse
    expect(user).to_not be_valid
  end

  it 'is valid with password equals to password_confirmation' do
    password = ('a'..'z').to_a.join
    user = build(:user, password: password)
    user.password_confirmation = password
    expect(user).to be_valid
  end

  it 'should validate the user with password' do
    password = ('a'..'z').to_a.join
    user = create(:user, password: password)
    expect(user.authenticate password).to eq(user)
  end

  it 'should not validate the user with a wrong password' do
    password = ('a'..'z').to_a.join
    user = create(:user, password: password)
    expect(user.authenticate password.reverse).to_not be_truthy
  end

  it 'should have secure tokens' do
    user = create(:user)
    token1 = user.secure_tokens.create
    token2 = user.secure_tokens.create

    expect(token1.user).to eq(user)
    expect(token2.user).to eq(user)
  end

  it 'should have recipes' do
    user = create(:user)
    r = build(:recipe, user: nil)
    recipe1 = user.recipes.create r.attributes
    r = build(:recipe, user: nil)
    recipe2 = user.recipes.create r.attributes

    expect(recipe1.user).to eq(user)
    expect(recipe2.user).to eq(user)
  end

end
