class Dbconsistency < ActiveRecord::Migration[8.1]
  def change
    remove_index :usercats, :category_id
    remove_index :recommendations, :paper_id
    remove_index :hidden_papers, :paper_id
    remove_index :followships, :author_id
    remove_index :categorisations, :paper_id
    remove_index :bookmarks, :paper_id
    remove_index :authorships, :paper_id
    change_column_null :papers, :arxiv, false
    change_column_null :categories, :arxiv, false
    change_column_null :authors, :arxiv, false
    change_column_null :authors, :name_variants, false
    add_index :authorships, %i[paper_id author_id], unique: true
    remove_foreign_key :users, :subjects
    add_foreign_key :users, :subjects, on_delete: :nullify
  end
end
