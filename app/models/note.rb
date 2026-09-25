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
  validate :review_content_must_be_short

  def word_count
    content.to_s.split.size
  end

  def content_length
    utility.note_content_length(self)
  end

  private

  def review_content_must_be_short
    return unless review?
    return if utility.blank?
    return if utility.short_note?(self)

    errors.add(:content, :review_too_long)
  end
end
