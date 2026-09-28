class NorthUtility < Utility
  private

  def short_note?(note)
    note.word_count <= 50
  end

  def medium_note?(note)
    note.word_count <= 100
  end
end
