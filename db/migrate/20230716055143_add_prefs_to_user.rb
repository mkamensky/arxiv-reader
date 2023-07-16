class AddPrefsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :prefs, :jsonb, null: false, default: {}
  end
end
