class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do
      it.references :user, null: false, foreign_key: true, index: false
      it.string :val, null: false
      it.string :title
      it.string :color, null: false, default: '#2468ace0'

      it.timestamps
    end
    add_index :tags, %i[user_id val], unique: true
  end
end
