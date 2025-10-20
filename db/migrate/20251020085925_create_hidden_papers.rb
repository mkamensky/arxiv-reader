class CreateHiddenPapers < ActiveRecord::Migration[8.0]
  def change
    create_table :hidden_papers do
      it.references :user, null: false, foreign_key: true, index: true
      it.references :paper, null: false, foreign_key: true, index: true

      it.timestamps
    end
    add_index :hidden_papers, %i[paper_id user_id], unique: true
  end
end
