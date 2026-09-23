# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  content    :text             not null
#  note_type  :integer          not null
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  belongs_to :user
  has_one :utility, through: :user
  enum note_type: { review: 0, critique: 1 }
  validates :title, :content, :note_type, presence: true
  validate :review_content_within_limit
  def word_count
    content.to_s.split.size
  end

  def content_length
    limits = utility.note_content_limits

    return 'short' if word_count <= limits[:short]
    return 'medium' if word_count <= limits[:medium]

    'long'
  end

  private

  def review_content_within_limit
    return unless review?
    return if user.blank? || content.blank?

    max_words = utility.note_content_limits[:short]
    return if word_count <= max_words

    errors.add(:content, :review_too_long, max_words: max_words)
  end
end
