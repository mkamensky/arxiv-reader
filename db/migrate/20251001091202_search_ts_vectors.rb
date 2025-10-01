class SearchTsVectors < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL.squish
      ALTER TABLE papers
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(abstract,'')), 'B') ||
        setweight(to_tsvector('english', coalesce(comment,'')), 'C')
      ) STORED;
    SQL
  end

  def down
    remove_column :papers, :searchable
  end
end
