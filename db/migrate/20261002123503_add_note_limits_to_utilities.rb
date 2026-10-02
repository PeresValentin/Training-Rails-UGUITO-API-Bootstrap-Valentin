class AddNoteLimitsToUtilities < ActiveRecord::Migration[6.1]
  def up
    add_column :utilities, :short_note_limit, :integer
    add_column :utilities, :medium_note_limit, :integer

    set_note_limits('NorthUtility', 50, 100)
    set_note_limits('SouthUtility', 60, 120)

    change_column_null :utilities, :short_note_limit, false
    change_column_null :utilities, :medium_note_limit, false
  end

  def down
    remove_column :utilities, :medium_note_limit
    remove_column :utilities, :short_note_limit
  end

  private

  def set_note_limits(type, short_note_limit, medium_note_limit)
    execute <<~SQL.squish
      UPDATE utilities
      SET short_note_limit = #{short_note_limit}, medium_note_limit = #{medium_note_limit}
      WHERE type = '#{type}'
    SQL
  end
end
