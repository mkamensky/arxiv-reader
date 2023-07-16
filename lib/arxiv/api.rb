# frozen_string_literal: true

module Arxiv
  module Api
    class Paper
      attr_accessor :id, :version, :comment, :authors, :abs, :pdf,
                    :published, :summary, :tags, :title, :updated, :journal_ref,
                    :arxiv_primary_category

      ATTR_TRANS = {
        _rawid: :id,
        id: :url,
        _version: :version,
        arxiv_comment: :comment,
        arxiv_journal_ref: :journal_ref,
      }.freeze

      def initialize(**attrs)
        attrs.each do |k, v|
          setter = (ATTR_TRANS[k.to_sym] || k).to_s + '='
          #puts "#{setter}#{v.inspect}"
          try(setter, v)
        end
      end

      def links=(vals)
        vals.each do |lnk|
          setter = (lnk['title'] || 'abs') + '='
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
        @author_names ||= authors.map { |aa| aa['name'] }
      end

      def tag_values
        @tag_values ||= tags.map { |aa| aa['term'] }
      end

      def self.is_arxiv?(tag) # TODO
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

      def self.from_json(jsn)
        res = {}
        jsn.each do |k, v|
          res[k] = new(**v)
        end
        res
      end

      def self.from_file(file)
        from_json(File.open(file) { |fh| JSON.load(fh) })
      end
    end
  end
end

