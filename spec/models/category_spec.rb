require 'rails_helper'

RSpec.describe Category, type: :model do

  it 'has valid factory' do
    category = create(:category)
    expect(category).to be_valid
  end

  it 'requires name' do
    category = build(:category, name: nil)
    expect(category).to_not be_valid
  end

end
