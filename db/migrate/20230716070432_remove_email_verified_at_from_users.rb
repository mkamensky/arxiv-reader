class RemoveEmailVerifiedAtFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :email_verified_at, :datetime
  end
end
