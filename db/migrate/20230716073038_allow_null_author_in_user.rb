class AllowNullAuthorInUser < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :author_id, true
  end
end
