class AddSubjectToCategory < ActiveRecord::Migration[7.0]
  def change
    add_reference :categories, :subject, null: false, foreign_key: true
  end
end
