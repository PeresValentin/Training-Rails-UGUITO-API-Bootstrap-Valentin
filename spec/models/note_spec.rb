require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    build(:note)
  end

  %i[title content note_type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_one(:utility).through(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end
end