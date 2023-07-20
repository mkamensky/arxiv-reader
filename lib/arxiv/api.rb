# frozen_string_literal: true

module Arxiv
  module Api
    class Paper
      attr_accessor :id, :version, :comment, :authors, :url, :pdf_url,
                    :doi, :doi_url, :category, :categories,
                    :published, :summary, :tags, :title, :updated,
                    :journal_ref, :_debug

      ATTR_TRANS = {
        _id: :id,
        entry_id: :id,
        title_type: :_,
        id: :url,
        _version: :version,
        arxiv_comment: :comment,
        arxiv_journal_ref: :journal_ref,
      }.freeze
      private_constant :ATTR_TRANS

      class << self
        # TODO
        def arxiv?(tag)
          tag =~ /^math\.[A-Z][A-Z]$/
        end

        def from_hash(jsn)
          res = {}
          jsn.each do |k, v|
            res[k] = new(**v)
          end
          res
        end

        def from_file(file)
          # rubocop: disable Security/JSONLoad
          from_hash(File.open(file) { |fh| JSON.load(fh) })
          # rubocop: enable Security/JSONLoad
        end

        def from_db(file)
          res = {}
          require 'sqlite3'
          db = SQLite3::Database.new file
          db.execute('select * from papers') do |row|
            res[row[0]] = new(**JSON.parse(row[1]))
          end
          res
        end

        def client(**opts)
          require 'faraday'
          @client ||= Faraday.new(
            url: 'http://export.arxiv.org/api/',
            **opts,
          ) do |f|
            ##f.response :raise_error
          end
        end

        def get(*args)
          # obey time limit
          # rubocop:disable Rails/TimeZone
          delay = @lastget.present? ? @lastget + 3.seconds - Time.now : 0
          sleep(delay) if delay.positive?
          @lastget = Time.now
          # rubocop:enable Rails/TimeZone
          client.get(*args)
        end

        def from_arxiv(search, **opts)
          search = search.respond_to?(:map) ? search.map { |k, v| "#{k}:#{v}" }.join('+AND+') : "all:#{search}"
          resp = get(
            'query',
            search_query: search,
            max_results: 100,
            sortBy: :lastUpdatedDate,
            sortOrder: :descending,
            **opts,
          )
          require 'feedjira'
          require 'feedjira/parser/atom_arxiv'

          feed = Feedjira.parse(resp.body)

        end
      end

      def initialize(**attrs)
        attrs.each do |k, v|
          setter = "#{ATTR_TRANS[k.to_sym] || k}="
          #puts "#{setter}#{v.inspect}"
          try(setter, v)
        end
        self._debug = attrs
      end

      def links=(vals)
        vals.each do |lnk|
          setter = "#{lnk['title'] || 'abs'}="
          #puts "#{setter}#{lnk['href']}"
          try(setter, lnk['href'])
        end
      end

      def submitted
        @submitted ||= Date.parse(published)
      end

      def revised
        @revised ||= Date.parse(updated)
      end

      def author_names
        @author_names ||= authors.pluck('name')
      end

      def tag_values
        @tag_values ||= tags.pluck('term')
      end

      def secondaries
        @secondaries ||= tag_values - aux_tags - [category]
      end

      def aux_tags
        @aux_tags ||= tag_values.reject { |x| self.class.arxiv?(x) }
      end
    end
  end
end
