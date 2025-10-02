class CreateUsercats < ActiveRecord::Migration[8.0]
  def change
    create_table :usercats do
      it.references :user, null: false, foreign_key: true, index: true
      it.references :category, null: false, foreign_key: true, index: true

      it.timestamps
    end
    add_index :usercats, %i[category_id user_id], unique: true
  end
end
