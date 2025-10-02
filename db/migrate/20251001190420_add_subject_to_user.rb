class AddSubjectToUser < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :subject, null: true, foreign_key: true
  end
end
