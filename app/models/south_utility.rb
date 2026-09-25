class SouthUtility < Utility
  def short_note?(note)
    note.word_count <= 60
  end

  private

  def medium_note?(note)
    note.word_count <= 120
  end
end
