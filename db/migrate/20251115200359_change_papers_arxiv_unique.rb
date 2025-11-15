class ChangePapersArxivUnique < ActiveRecord::Migration[8.1]
  def change
    remove_index :papers, %i[arxiv version]
    remove_index :papers, :arxiv
    add_index :papers, :arxiv, unique: true
  end

  def data_before
    Paper.find_each do |paper|
      # rubocop: disable Style/ItBlockParameter
      alr = Paper.where(arxiv: paper.arxiv).order(version: :asc)
      # rubocop: enable Style/ItBlockParameter
      next if alr.length <= 1

      al = alr.to_a
      orig = al.shift
      attrs = []
      al.each do
        attrs.push(it.attributes.except(*%w[id created_at updated_at]))
        warn "Found extra version #{it.version} of paper #{orig.arxiv}"
        it.destroy!
      end
      attrs.each { orig.update!(it) }
    end
  end

end
