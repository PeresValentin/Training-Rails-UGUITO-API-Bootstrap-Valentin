require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:notes) { create_list(:note, 3) }

    let!(:expected) do
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
  end
end