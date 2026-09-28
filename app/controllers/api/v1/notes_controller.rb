module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      private

      def notes
        Note.all
      end
    end
  end
end