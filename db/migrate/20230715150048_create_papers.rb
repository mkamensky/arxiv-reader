class CreatePapers < ActiveRecord::Migration[7.0]
  def change
    create_table :papers do |t|
      t.string :arxiv
      t.string :title
      t.text :abstract
      t.string :version
      t.date :submitted, null: false
      t.date :revised
      t.references :category, null: false, foreign_key: true
      t.text :comment
      t.string :abs, null: false
      t.string :pdf
      t.string :tags, array: true, default: []
      t.string :journal_ref

      t.timestamps
    end
    add_index :papers, :arxiv
    add_index :papers, :submitted
    add_index :papers, :tags
    add_index :papers, %i[arxiv version], unique: true
  end
end
