require 'rails_helper'

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

  describe '#word_count' do
    context 'when content has words' do
      let(:words) { Faker::Number.between(from: 1, to: 50) }
      let(:note) { build(:note, content: Faker::Lorem.sentence(word_count: words)) }

      it 'returns the number of words' do
        expect(note.word_count).to eq(words)
      end
    end

    context 'when content has extra spaces' do
      let(:note) { build(:note, content: '  una   nota  ') }

      it 'returns 2' do
        expect(note.word_count).to eq(2)
      end
    end
  end

  describe '#content_length' do
    let(:user) { create(:user, utility: utility) }
    let(:note) do
      build(
        :note,
        user: user,
        content: ('word ' * content_words).strip
      )
    end

    context 'when utility is North' do
      let(:utility) { create(:north_utility) }

      context 'when content is at the short limit' do
        let(:content_words) { 50 }

        it 'returns short' do
          expect(note.content_length).to eq('short')
        end
      end

      context 'when content exceeds the short limit' do
        let(:content_words) { 51 }

        it 'returns medium' do
          expect(note.content_length).to eq('medium')
        end
      end

      context 'when content is at the medium limit' do
        let(:content_words) { 100 }

        it 'returns medium' do
          expect(note.content_length).to eq('medium')
        end
      end

      context 'when content exceeds the medium limit' do
        let(:content_words) { 101 }

        it 'returns long' do
          expect(note.content_length).to eq('long')
        end
      end
    end

    context 'when utility is South' do
      let(:utility) { create(:south_utility) }

      context 'when content is at the short limit' do
        let(:content_words) { 60 }

        it 'returns short' do
          expect(note.content_length).to eq('short')
        end
      end

      context 'when content exceeds the short limit' do
        let(:content_words) { 61 }

        it 'returns medium' do
          expect(note.content_length).to eq('medium')
        end
      end

      context 'when content is at the medium limit' do
        let(:content_words) { 120 }

        it 'returns medium' do
          expect(note.content_length).to eq('medium')
        end
      end

      context 'when content exceeds the medium limit' do
        let(:content_words) { 121 }

        it 'returns long' do
          expect(note.content_length).to eq('long')
        end
      end
    end
  end

  describe 'review content limit' do
    let(:user) { create(:user, utility: utility) }
    let(:note) do
      build(
        :note,
        user: user,
        note_type: :review,
        content: ('word ' * content_words).strip
      )
    end

    context 'without user' do
      let(:note) { build(:note, user: nil) }

      it 'does not raise an error' do
        expect { note.valid? }.not_to raise_error
      end
    end

    context 'when utility is North' do
      let(:utility) { create(:north_utility) }

      context 'when content is at the limit' do
        let(:content_words) { 50 }

        it 'is valid' do
          expect(note).to be_valid
        end
      end

      context 'when content exceeds the limit' do
        let(:content_words) { 51 }

        it 'is invalid' do
          expect(note).not_to be_valid
        end

        it 'adds an error to content' do
          note.valid?

          expect(note.errors.added?(:content, :review_too_long)).to be(true)
        end
      end
    end

    context 'when utility is South' do
      let(:utility) { create(:south_utility) }

      context 'when content is at the limit' do
        let(:content_words) { 60 }

        it 'is valid' do
          expect(note).to be_valid
        end
      end

      context 'when content exceeds the limit' do
        let(:content_words) { 61 }

        it 'is invalid' do
          expect(note).not_to be_valid
        end

        it 'adds an error to content' do
          note.valid?

          expect(note.errors.added?(:content, :review_too_long)).to be(true)
        end
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

  it 'has a valid factory' do
    expect(note).to be_valid
  end
end
