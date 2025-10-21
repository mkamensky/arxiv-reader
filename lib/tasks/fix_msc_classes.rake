require 'arxiv/api'

namespace :dbfixes do
  desc 'correct msc classes containing "primary" and "secondary"'
  task fix_msc: :environment do
    Paper.where(
      "array_to_string(\"primary\", '') SIMILAR TO ?",
      '%([Pp]rimary|[Ss]econdary)%',
    ).find_each do
      cls = it.primary.join(', ') + it.secondary.join(', ')
      prsd = Arxiv::Api.parse_msc(cls)
      Rails.logger.info(
        "#{it.arxiv}: '#{cls}' => '#{prsd&.first}; #{prsd&.second || ''}'",
      )
      it.primary = prsd&.first || []
      it.secondary = prsd&.second || []
      it.save!
    end
  end
end
