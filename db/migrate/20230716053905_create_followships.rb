class CreateFollowships < ActiveRecord::Migration[7.0]
  def change
    create_table :followships do |t|
      t.references :author, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
    add_index :followships, %i[author_id user_id], unique: true
  end
end
