module Api
  module V1
    class NotesController < ApplicationController
      MAX_PAGE_SIZE = 100

      before_action :validate_index_params, only: :index

      def index
        render json: notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      private

      def notes
        Note.includes(:utility)
            .with_type(params[:type])
            .ordered_by_creation(params[:order])
            .page(params[:page])
            .per(params[:page_size])
            .max_paginates_per(MAX_PAGE_SIZE)
      end

      def show_note
        Note.find(params[:id])
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
    end
  end
end
