module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      private

      def notes
        def notes
  Note.with_type(params[:type])
      .ordered_by_creation(params[:order])
      .page(params[:page])
      .per(params[:page_size])
end
      end
    end
  end
end