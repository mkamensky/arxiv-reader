class AddFieldsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :avatar, :string, null: true
    add_column :users, :github, :string, null: true
    add_index :users, :github,  nulls_not_distinct: true
  end
end
