class AddNameVariantsToAuthor < ActiveRecord::Migration[8.0]
  def change
    add_column :authors, :name_variants, :string, array: true, default: []
    add_index :authors, :name_variants
  end
end
