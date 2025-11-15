# This migration creates the `paper_versions` table for the PaperVersion class.
# All other migrations PT provides are optional.
class CreatePaperVersions < ActiveRecord::Migration[8.1]
  def change
    # rubocop: disable Style/ItBlockParameter
    create_table :paper_versions do |t|
      t.bigint   :whodunnit

      t.datetime :created_at

      t.references :item, null: false, foreign_key: { to_table: :papers },
        index: true
      t.string :event, null: false
      t.jsonb :object
      t.jsonb :object_changes
    end
    # rubocop: enable Style/ItBlockParameter
  end
end
