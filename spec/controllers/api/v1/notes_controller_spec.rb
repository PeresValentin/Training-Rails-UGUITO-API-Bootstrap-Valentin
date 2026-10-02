require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    shared_examples 'responds with the expected notes' do
      it 'responds with the expected notes' do
        expect(response_body).to match_array(expected)
      end
    end

    shared_examples 'responds with the expected notes in order' do
      it 'responds with the expected notes in order' do
        expect(response_body).to eq(expected)
      end
    end

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let_it_be(:user) { create(:user) }
      let_it_be(:reviews) { create_list(:note, 3, note_type: :review, user: user) }
      let_it_be(:critiques) { create_list(:note, 2, note_type: :critique, user: user) }
      let_it_be(:other_user_note) { create(:note) }

      let(:notes) { reviews + critiques }

      let(:expected) do
        JSON.parse(
          ActiveModel::Serializer::CollectionSerializer.new(
            notes_expected,
            serializer: IndexNoteSerializer
          ).to_json
        )
      end

      context 'when fetching all the notes' do
        let(:notes_expected) { notes }

        before { get :index }

        it_behaves_like 'responds with the expected notes'

        it 'does not include notes from other users' do
          expect(response_body.pluck('id')).not_to include(other_user_note.id)
        end

        it_behaves_like 'ok response'
      end

      context 'when filtering by review type' do
        let(:notes_expected) { reviews }

        before { get :index, params: { type: 'review' } }

        it_behaves_like 'responds with the expected notes'

        it_behaves_like 'ok response'
      end

      context 'when filtering by critique type' do
        let(:notes_expected) { critiques }

        before { get :index, params: { type: 'critique' } }

        it_behaves_like 'responds with the expected notes'

        it_behaves_like 'ok response'
      end

      context 'when ordering by creation date ascending' do
        let(:notes_expected) { notes.sort_by(&:created_at) }

        before { get :index, params: { order: 'asc' } }

        it_behaves_like 'responds with the expected notes in order'

        it_behaves_like 'ok response'
      end

      context 'when ordering by creation date descending' do
        let(:notes_expected) { notes.sort_by(&:created_at).reverse }

        before { get :index, params: { order: 'desc' } }

        it_behaves_like 'responds with the expected notes in order'

        it_behaves_like 'ok response'
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

        it_behaves_like 'responds with the expected notes in order'

        it_behaves_like 'ok response'
      end

      context 'when page size exceeds the maximum' do
        before do
          create_list(:note, described_class::MAX_PAGE_SIZE, user: user)
          get :index, params: { page_size: described_class::MAX_PAGE_SIZE + 1 }
        end

        it 'responds with the maximum page size' do
          expect(response_body.size).to eq(described_class::MAX_PAGE_SIZE)
        end
      end

      context 'when combining type, order and pagination' do
        let(:notes_expected) do
          reviews
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

        it_behaves_like 'responds with the expected notes in order'

        it_behaves_like 'ok response'
      end

      context 'when type param is empty' do
        let(:notes_expected) { notes }

        before { get :index, params: { type: '' } }

        it_behaves_like 'responds with the expected notes'

        it_behaves_like 'ok response'
      end

      context 'when order param is empty' do
        let(:notes_expected) { notes }

        before { get :index, params: { order: '' } }

        it_behaves_like 'responds with the expected notes'

        it_behaves_like 'ok response'
      end

      context 'when type param is invalid' do
        let(:message) { I18n.t('errors.messages.invalid_note_type') }

        before { get :index, params: { type: 'banana' } }

        it_behaves_like 'bad request with message'
      end

      context 'when order param is invalid' do
        let(:message) { I18n.t('errors.messages.invalid_order') }

        before { get :index, params: { order: 'banana' } }

        it_behaves_like 'bad request with message'
      end
    end

    context 'when there is not a user logged in' do
      before { get :index }

      it_behaves_like 'unauthorized'
    end
  end

  describe 'GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let_it_be(:user) { create(:user) }

      context 'when the note belongs to the user' do
        let_it_be(:note) { create(:note, user: user) }
        let(:record) { note }
        let(:expected) { ShowNoteSerializer.new(note).to_json }

        before { get :show, params: { id: note.id } }

        it_behaves_like 'basic show endpoint'

        it 'responds with the expected note json' do
          expect(response_body.to_json).to eq(expected)
        end
      end

      context 'when the note belongs to another user' do
        let(:note) { create(:note) }

        before { get :show, params: { id: note.id } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the note does not exist' do
        before { get :show, params: { id: -1 } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when there is not a user logged in' do
      let(:note) { create(:note) }

      before { get :show, params: { id: note.id } }

      it_behaves_like 'unauthorized'
    end
  end

  describe 'POST #create' do
    shared_examples 'note not created with error' do
      it 'responds with the error status' do
        expect(response).to have_http_status(status)
      end

      it 'responds with the error message' do
        expect(response_body).to eq('error' => message)
      end

      it 'does not create a note' do
        expect(Note.count).to eq(0)
      end
    end

    let(:note_params) do
      {
        title: Faker::Book.title,
        type: Note.note_types.keys.sample,
        content: Faker::Lorem.sentence(word_count: 20)
      }
    end

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let_it_be(:user) { create(:user) }

      let(:long_content) { Faker::Lorem.sentence(word_count: 200) }

      context 'when the params are valid' do
        before { post :create, params: { note: note_params } }

        it 'responds with 201 status' do
          expect(response).to have_http_status(:created)
        end

        it 'responds with the created message' do
          expect(response_body).to eq('message' => 'Nota creada con exito.')
        end

        it 'creates the note for the authenticated user' do
          expect(user.notes.first).to have_attributes(
            title: note_params[:title],
            note_type: note_params[:type],
            content: note_params[:content]
          )
        end
      end

      context 'when a critique exceeds the review word limit' do
        before do
          post :create, params: { note: note_params.merge(type: 'critique', content: long_content) }
        end

        it 'responds with 201 status' do
          expect(response).to have_http_status(:created)
        end

        it 'creates the note' do
          expect(user.notes.count).to eq(1)
        end
      end

      context 'when a user_id of another user is sent' do
        let(:other_user) { create(:user) }

        before { post :create, params: { note: note_params.merge(user_id: other_user.id) } }

        it 'creates the note for the authenticated user' do
          expect(user.notes.count).to eq(1)
        end
      end

      context 'when a required param is missing' do
        let(:status) { :bad_request }
        let(:message) { 'Faltan parametros requeridos.' }

        context 'when the note param is missing' do
          before { post :create }

          it_behaves_like 'note not created with error'
        end

        context 'when title is missing' do
          before { post :create, params: { note: note_params.except(:title) } }

          it_behaves_like 'note not created with error'
        end

        context 'when type is missing' do
          before { post :create, params: { note: note_params.except(:type) } }

          it_behaves_like 'note not created with error'
        end

        context 'when content is missing' do
          before { post :create, params: { note: note_params.except(:content) } }

          it_behaves_like 'note not created with error'
        end
      end

      context 'when the type is invalid' do
        let(:status) { :unprocessable_entity }
        let(:message) { 'El tipo de nota no es válido.' }

        before { post :create, params: { note: note_params.merge(type: 'banana') } }

        it_behaves_like 'note not created with error'
      end

      context 'when a review exceeds the word limit' do
        let(:status) { :unprocessable_entity }
        let(:message) { 'es demasiado largo para una review' }

        before do
          post :create, params: { note: note_params.merge(type: 'review', content: long_content) }
        end

        it_behaves_like 'note not created with error'
      end
    end

    context 'when there is not a user logged in' do
      before { post :create, params: { note: note_params } }

      it_behaves_like 'unauthorized'

      it 'does not create a note' do
        expect(Note.count).to eq(0)
      end
    end
  end
end
