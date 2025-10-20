class AddOrcidToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :orcid, :string, null: true
    add_index :users, :orcid, nulls_not_distinct: true
  end
end
