class AddIndexToSearchablePapers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :papers, :searchable, using: :gin, algorithm: :concurrently
  end
end
