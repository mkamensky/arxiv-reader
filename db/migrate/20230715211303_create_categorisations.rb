class CreateCategorisations < ActiveRecord::Migration[7.0]
  def change
    create_table :categorisations do |t|
      t.references :paper, null: false, foreign_key: true, index: true
      t.references :category, null: false, foreign_key: true, index: true

      t.timestamps
    end
    add_index :categorisations, %i[paper_id category_id], unique: true
  end
end
