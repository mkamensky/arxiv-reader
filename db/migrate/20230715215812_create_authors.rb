class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :name, null: false
      t.string :arxiv

      t.timestamps
    end
    add_index :authors, :arxiv, unique: true
  end
end
