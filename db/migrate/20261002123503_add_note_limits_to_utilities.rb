class AddNoteLimitsToUtilities < ActiveRecord::Migration[6.1]
  def change
    add_column :utilities, :short_note_limit, :integer
    add_column :utilities, :medium_note_limit, :integer
  end
end
