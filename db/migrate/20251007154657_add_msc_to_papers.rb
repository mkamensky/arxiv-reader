class AddMscToPapers < ActiveRecord::Migration[8.0]
  def change
    add_column :papers, :primary, :string, array: true, default: []
    add_column :papers, :secondary, :string, array: true, default: []
  end
end
