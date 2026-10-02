module Api
  module V1
    class NotesController < ApplicationController
      MAX_PAGE_SIZE = 100

      before_action :authenticate_user!
      before_action :validate_index_params, only: :index
      before_action :validate_create_params, only: :create

      def index
        render json: notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      def create
        current_user.notes.create!(note_params)
        render json: { message: I18n.t('notes.created') }, status: :created
      end

      private

      def notes
        current_user.notes
                    .includes(:utility)
                    .with_type(params[:type])
                    .ordered_by_creation(params[:order])
                    .page(params[:page])
                    .per(params[:page_size])
                    .max_paginates_per(MAX_PAGE_SIZE)
      end

      def show_note
        current_user.notes.find(params[:id])
      end

      def validate_index_params
        return render_error(:invalid_note_type) if invalid_type?

        render_error(:invalid_order) if invalid_order?
      end

      def invalid_type?
        params[:type].present? && !Note.note_types.key?(params[:type])
      end

      def invalid_order?
        params[:order].present? && !%w[asc desc].include?(params[:order])
      end

      def note_params
        note = params.require(:note)
        note.require(%i[title type content])
        note.permit(:title, :content).merge(note_type: note[:type])
      end

      def validate_create_params
        return if Note.note_types.key?(note_params[:note_type])

        render_simple_error(I18n.t('errors.messages.invalid_note_type'), :unprocessable_entity)
      end
    end
  end
end
