class NorthUtility < Utility
  def short_note?(note)
    note.word_count <= 50
  end

  private

  def medium_note?(note)
    note.word_count <= 100
  end
end
