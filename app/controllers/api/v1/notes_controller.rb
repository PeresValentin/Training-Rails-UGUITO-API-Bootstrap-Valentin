module Api
  module V1
    class NotesController < ApplicationController
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
        note = current_user.notes.new(note_params)
        if note.save
          render json: { message: I18n.t('notes.created') }, status: :created
        else
          error = note.errors.first
          render_error(error.type, message: error.message, status: :unprocessable_entity)
        end
      end

      private

      def notes
        current_user.notes
                    .includes(:utility)
                    .with_type(params[:type])
                    .ordered_by_creation(params[:order])
                    .page(pagination_params[:page])
                    .per(pagination_params[:page_size])
      end

      def pagination_params
        params.permit(:page, :page_size)
      end

      def show_note
        current_user.notes.find(params[:id])
      end

      def validate_index_params
        raise Exceptions::InvalidParameterError, 'invalid_note_type' if invalid_type?
        raise Exceptions::InvalidParameterError, 'invalid_order' if invalid_order?
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

        render_error(:invalid_note_type, status: :unprocessable_entity)
      end
    end
  end
end
