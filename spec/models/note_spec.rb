require 'rails_helper'

shared_examples 'content length by word limits' do
  let(:note) do
    build(
      :note,
      user: user,
      content: ('word ' * content_words).strip
    )
  end

  context 'when content is at the short limit' do
    let(:content_words) { short_limit }

    it 'returns short' do
      expect(note.content_length).to eq('short')
    end
  end

  context 'when content exceeds the short limit' do
    let(:content_words) { short_limit + 1 }

    it 'returns medium' do
      expect(note.content_length).to eq('medium')
    end
  end

  context 'when content is at the medium limit' do
    let(:content_words) { medium_limit }

    it 'returns medium' do
      expect(note.content_length).to eq('medium')
    end
  end

  context 'when content exceeds the medium limit' do
    let(:content_words) { medium_limit + 1 }

    it 'returns long' do
      expect(note.content_length).to eq('long')
    end
  end
end

shared_examples 'review limited to short content' do
  let(:note) do
    build(
      :note,
      user: user,
      note_type: :review,
      content: ('word ' * content_words).strip
    )
  end

  context 'when content is at the limit' do
    let(:content_words) { short_limit }

    it 'is valid' do
      expect(note).to be_valid
    end
  end

  context 'when content exceeds the limit' do
    let(:content_words) { short_limit + 1 }

    it 'is invalid' do
      expect(note).not_to be_valid
    end

    it 'adds an error to content' do
      note.valid?

      expect(note.errors.added?(:content, :review_too_long, limit: short_limit)).to be(true)
    end
  end
end

RSpec.describe Note, type: :model do
  subject(:note) do
    build(:note)
  end

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_presence_of(:note_type) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_one(:utility).through(:user) }

  it 'defines review and critique types' do
    expect(note).to define_enum_for(:note_type)
      .with_values(review: 0, critique: 1)
  end

  it 'rejects an invalid note type' do
    expect { build(:note, note_type: :invalid) }.to raise_error(ArgumentError)
  end

  it 'has a valid factory' do
    expect(note).to be_valid
  end

  describe '#word_count' do
    context 'when content has words' do
      let(:content_words) { Faker::Number.between(from: 1, to: 50) }
      let(:note) { build(:note, content: Faker::Lorem.sentence(word_count: content_words)) }

      it 'returns the number of words' do
        expect(note.word_count).to eq(content_words)
      end
    end
  end

  describe '#content_length' do
    let(:user) { create(:user, utility: utility) }

    context 'when utility is North' do
      let(:utility) { create(:north_utility) }

      it_behaves_like 'content length by word limits' do
        let(:short_limit) { 50 }
        let(:medium_limit) { 100 }
      end
    end

    context 'when utility is South' do
      let(:utility) { create(:south_utility) }

      it_behaves_like 'content length by word limits' do
        let(:short_limit) { 60 }
        let(:medium_limit) { 120 }
      end
    end
  end

  describe 'review content limit' do
    let(:user) { create(:user, utility: utility) }

    context 'without user' do
      let(:note) { build(:note, user: nil) }

      it 'does not raise an error' do
        expect { note.valid? }.not_to raise_error
      end
    end

    context 'when utility is North' do
      let(:utility) { create(:north_utility) }

      it_behaves_like 'review limited to short content' do
        let(:short_limit) { 50 }
      end
    end

    context 'when utility is South' do
      let(:utility) { create(:south_utility) }

      it_behaves_like 'review limited to short content' do
        let(:short_limit) { 60 }
      end
    end
  end

  describe 'critique content limit' do
    let(:utility) { create(:north_utility) }
    let(:user) { create(:user, utility: utility) }

    let(:note) do
      build(
        :note,
        user: user,
        note_type: :critique,
        content: ('word ' * 101).strip
      )
    end

    it 'is valid' do
      expect(note).to be_valid
    end
  end
end
