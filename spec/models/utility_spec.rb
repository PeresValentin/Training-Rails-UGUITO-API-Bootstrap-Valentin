require 'rails_helper'

RSpec.describe Utility, type: :model do
  subject(:utility) do
    build(:utility)
  end

  %i[name type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { is_expected.to have_many(:users).dependent(:destroy) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe '#note_content_length' do
    context 'when the rules are not implemented' do
      it 'raises NotImplementedError' do
        expect { described_class.new.note_content_length(Note.new) }
          .to raise_error(NotImplementedError)
      end
    end

    Rails.application.eager_load!

    described_class.subclasses.each do |utility_class|
      context "with #{utility_class}" do
        it 'implements short_note?' do
          expect(utility_class.instance_method(:short_note?).owner).to eq(utility_class)
        end

        it 'implements medium_note?' do
          expect(utility_class.instance_method(:medium_note?).owner).to eq(utility_class)
        end
      end
    end
  end
end
