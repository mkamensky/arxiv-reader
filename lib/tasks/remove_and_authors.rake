namespace :dbfixes do
  desc 'remove authors starting with the word and'
  task remove_and: :environment do
    Author.where('name LIKE ?', 'and %').find_each do
      name = it.name.delete_prefix('and ')
      warn "Fixing '#{it.name}' to '#{name}'..."
      good = Author.find_by(name:)
      begin
        if good
          warn "  Found #{name}, moving papers and users, and destroying #{it.name}"
          good.papers |= it.papers
          good.users |= it.users
          it.destroy!
        else
          warn "  No user by the name #{name}, renaming the broken one"
          it.name = name
          it.save!
        end
      rescue ActiveRecord::RecordInvalid => e
        debugger if Rails.env.local?
      end
    end
  end
end
