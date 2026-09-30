module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_index_params, only: :index
      before_action :validate_create_params, only: :create
      rescue_from ActionController::ParameterMissing, with: :render_missing_note_parameters

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
        raise Exceptions::InvalidNoteTypeError unless Note.note_types.key?(note_params[:note_type])
      end
    end
  end
end
