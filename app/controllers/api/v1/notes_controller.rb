module Api
  module V1
    class NotesController < ApplicationController
      before_action :validate_index_params, only: :index

      def index
        render json: notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      private

      def notes
        Note.includes(:user, :utility)
            .with_type(params[:type])
            .ordered_by_creation(params[:order])
            .page(params[:page])
            .per(params[:page_size])
      end

      def show_note
        Note.find(params.require(:id))
      end

      def validate_index_params
        return render json: { error: 'Invalid note type' }, status: :bad_request if invalid_type?
        return render json: { error: 'Invalid order' }, status: :bad_request if invalid_order?
      end

      def invalid_type?
        params[:type].present? && !Note.note_types.key?(params[:type])
      end

      def invalid_order?
        params[:order].present? && !%w[asc desc].include?(params[:order])
      end
    end
  end
end
