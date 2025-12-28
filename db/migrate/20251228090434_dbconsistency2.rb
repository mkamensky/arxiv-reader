class Dbconsistency2 < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :users, :authors
    add_foreign_key :users, :authors, on_delete: :nullify
    add_index :paper_tags, :tag_id
  end
end
