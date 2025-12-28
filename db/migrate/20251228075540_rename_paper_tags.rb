class RenamePaperTags < ActiveRecord::Migration[8.1]
  def change
    rename_column :papers, :tags, :arxiv_tags
  end
end
