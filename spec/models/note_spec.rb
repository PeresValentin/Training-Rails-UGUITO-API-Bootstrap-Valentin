require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    build(:note)
  end

  it 'has a valid factory' do
    expect(subject).to be_valid
  end
end