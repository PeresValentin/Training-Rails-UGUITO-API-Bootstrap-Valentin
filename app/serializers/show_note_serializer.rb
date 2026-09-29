class ShowNoteSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :word_count,
             :created_at,
             :content,
             :content_length

  attribute :note_type, key: :type

  belongs_to :user, serializer: UserSerializer
end
