class CreateSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :subjects do |t|
      t.string :title
      t.string :arxiv, null: false

      t.timestamps
    end
    add_index :subjects, :arxiv, unique: true
  end
end
