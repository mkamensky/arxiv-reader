# frozen_string_literal: true

module Arxiv
  module Api
    class Paper
      attr_accessor :id, :version, :comment, :authors, :abs, :pdf,
                    :published, :summary, :tags, :title, :updated, :journal_ref,
                    :arxiv_primary_category

      ATTR_TRANS = {
        _id: :id,
        id: :url,
        _version: :version,
        arxiv_comment: :comment,
        arxiv_journal_ref: :journal_ref,
      }.freeze
      private_constant :ATTR_TRANS

      def initialize(**attrs)
        attrs.each do |k, v|
          setter = "#{ATTR_TRANS[k.to_sym] || k}="
          #puts "#{setter}#{v.inspect}"
          try(setter, v)
        end
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

      # TODO
      def self.is_arxiv?(tag)
        tag =~ /^math\.[A-Z][A-Z]$/
      end

      def secondaries
        @secondaries ||= tag_values - aux_tags - [category]
      end

      def category
        @category ||= arxiv_primary_category['term']
      end

      def aux_tags
        @aux_tags ||= tag_values.reject { |x| self.class.is_arxiv?(x) }
      end

      def self.from_hash(jsn)
        res = {}
        jsn.each do |k, v|
          res[k] = new(**v)
        end
        res
      end

      def self.from_file(file)
        from_hash(File.open(file) { |fh| JSON.load(fh) })
      end

      def self.from_db(file)
        res = {}
        require 'sqlite3'
        db = SQLite3::Database.new file
        db.execute('select * from papers') do |row|
          res[row[0]] = new(**JSON.parse(row[1]))
        end
        res
      end
    end
  end
end
