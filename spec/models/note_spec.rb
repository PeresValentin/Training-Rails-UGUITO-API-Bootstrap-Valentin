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

  it do
  is_expected.to define_enum_for(:note_type)
    .with_values(review: 0, critique: 1)
  end
  it 'rejects an invalid note type' do
  expect { build(:note, note_type: :invalid) }.to raise_error(ArgumentError)
  end

  it 'has a valid factory' do
    expect(subject).to be_valid
  end
end