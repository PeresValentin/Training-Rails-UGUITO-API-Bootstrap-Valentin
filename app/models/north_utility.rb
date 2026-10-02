class NorthUtility < Utility
  private

  def short_note?(note)
    note.word_count <= short_note_limit
  end

  def medium_note?(note)
    note.word_count <= medium_note_limit
  end
end
