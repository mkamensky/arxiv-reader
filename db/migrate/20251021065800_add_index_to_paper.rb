class AddIndexToPaper < ActiveRecord::Migration[8.0]
  def change
    add_index :papers, :primary, using: 'gin'
    add_index :papers, :secondary, using: 'gin'
  end
end
