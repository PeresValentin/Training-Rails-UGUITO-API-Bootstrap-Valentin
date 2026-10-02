class SouthUtility < Utility
  private

  def short_note?(note)
    note.word_count <= 60
  end

  def medium_note?(note)
    note.word_count <= 120
  end
end
