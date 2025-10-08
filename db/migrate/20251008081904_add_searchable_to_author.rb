class AddSearchableToAuthor < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    execute <<-SQL.squish
      ALTER TABLE authors
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(array_to_tsvector(name_variants), 'B')
      ) STORED;
    SQL

    add_index :authors, :searchable, using: :gin, algorithm: :concurrently
  end

  def down
    remove_column :authors, :searchable
  end
end
