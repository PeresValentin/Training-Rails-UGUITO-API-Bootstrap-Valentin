require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let!(:notes) do
      [
        create(:note, note_type: :review, created_at: 4.days.ago),
        create(:note, note_type: :critique, created_at: 3.days.ago),
        create(:note, note_type: :review, created_at: 2.days.ago),
        create(:note, note_type: :critique, created_at: 1.day.ago),
        create(:note, note_type: :review, created_at: Time.current)
      ]
    end

    let(:expected) do
      ActiveModel::Serializer::CollectionSerializer.new(
        notes_expected,
        serializer: IndexNoteSerializer
      ).to_json
    end

    context 'when fetching all the notes' do
      let(:notes_expected) { notes }

      before { get :index }

      it 'responds with the expected notes json' do
        expect(response_body.to_json).to eq(expected)
      end

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when filtering by review type' do
      let(:notes_expected) { notes.select(&:review?) }

      before { get :index, params: { type: 'review' } }

      it 'responds with only review notes' do
        expect(response_body.to_json).to eq(expected)
      end

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when filtering by critique type' do
      let(:notes_expected) { notes.select(&:critique?) }

      before { get :index, params: { type: 'critique' } }

      it 'responds with only critique notes' do
        expect(response_body.to_json).to eq(expected)
      end

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when ordering by creation date ascending' do
      let(:notes_expected) { notes.sort_by(&:created_at) }

      before { get :index, params: { order: 'asc' } }

      it 'responds with notes ordered from oldest to newest' do
        expect(response_body.to_json).to eq(expected)
      end
    end

    context 'when ordering by creation date descending' do
      let(:notes_expected) { notes.sort_by(&:created_at).reverse }

      before { get :index, params: { order: 'desc' } }

      it 'responds with notes ordered from newest to oldest' do
        expect(response_body.to_json).to eq(expected)
      end
    end

    context 'when fetching notes with page and page size params' do
      let(:notes_expected) { notes.sort_by(&:created_at)[2, 2] }

      before do
        get :index, params: {
          page: 2,
          page_size: 2,
          order: 'asc'
        }
      end

      it 'responds with the expected page' do
        expect(response_body.to_json).to eq(expected)
      end

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when combining type, order and pagination' do
      let(:notes_expected) do
        notes
          .select(&:review?)
          .sort_by(&:created_at)
          .reverse
          .first(2)
      end

      before do
        get :index, params: {
          type: 'review',
          order: 'desc',
          page: 1,
          page_size: 2
        }
      end

      it 'responds with the expected notes' do
        expect(response_body.to_json).to eq(expected)
      end

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end