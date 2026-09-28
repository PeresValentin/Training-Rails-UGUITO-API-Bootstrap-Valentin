class IndexNoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :word_count, :content_length

  attribute :note_type, key: :type
end