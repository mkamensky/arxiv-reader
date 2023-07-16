class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :password_digest
      t.string :email, null: false
      t.string :name, default: ''
      t.references :author, null: false, foreign_key: true
      t.datetime :email_verified_at

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
