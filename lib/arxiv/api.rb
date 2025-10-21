# frozen_string_literal: true

module Arxiv
  # rubocop: disable Metrics/ModuleLength
  module Api
    extend self

    ARXIV_BASE = 'https://arxiv.org'
    public_constant :ARXIV_BASE
    def client(**)
      require 'faraday'
      require 'faraday/retry'
      require 'faraday/follow_redirects'
      @client ||= Faraday.new(url: 'http://export.arxiv.org/api/', **) do
        it.request(:retry, max: 5, retry_statuses: [429])
        it.response(:follow_redirects, limit: 5)
        ##f.response :raise_error
      end
    end

    def get(*)
      # obey time limit
      # rubocop:disable Rails/TimeZone
      delay = @lastget.present? ? @lastget + 3.seconds - Time.now : 0
      sleep(delay) if delay.positive?
      @lastget = Time.now
      # rubocop:enable Rails/TimeZone
      client.get(*)
    end

    def qget(**)
      resp = get('query', **)

      require 'feedjira'
      require 'feedjira/parser/atom_arxiv'

      Feedjira.parse(resp.body)
    end

    def as_val(val)
      val.respond_to?(:join) ? val.join('+OR+') : val
    end

    def get_by_id(id, **)
      qget(id_list: id).entries.first
    end

    def search(search, **)
      search = if search.is_a?(Hash)
        search.map { |k, v| "#{k}:#{as_val(v)}" }.join('+AND+')
      else
        "all:#{search}"
      end
      qget(
        search_query: search,
        max_results: 100,
        sortBy: :lastUpdatedDate,
        sortOrder: :descending,
        **,
      ).entries
    end

    def parse_authors(value)
      res = if value.is_a?(String)
        # from oai arxivRaw, TODO
        value.sub!(/with an appendix by.*$/i, '')
        /[()]/.match?(value) ? nil : value.split(/, (?!Jr[.]?)(?:and )?| and /)
      elsif value.is_a?(Hash)
        value['author']
      else
        # from atom
        JSON.parse(value.to_json)
      end
      res&.uniq { it.is_a?(Hash) ? it['name'] : it }
    end

    def parse_msc(value)
      @prim = @sec = nil
      if value =~ /^(.*) \(Primary\) *(.*) \(Secondary\)$/ ||
         value =~ /^Primary:? *(.*?)\.? *Secondary:? *(.*?)[. ]*$/

        @prim = $1
        @sec = $2
      else
        @prim = value
      end
      [ @prim.scan(/\d\d[A-Z-]\d\d/), @sec&.scan(/\d\d[A-Z-]\d\d/) ]
    end

    # rubocop:disable Rails/TimeZone, Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    def merge(hash, key, value)
      if key == 'authors'
        hash[key] = parse_authors(value)
      elsif key == 'creator'
        hash['authors'] ||= parse_authors(value)
      elsif key == 'date'
        hash[key] = Time.parse(value)
      elsif key == 'version'
        el = value.delete('version')
        hash[key] ||= {}
        hash[key][el] = value
      elsif key == 'categories'
        hash[key] = value.split
      elsif key == 'msc-class'
        hash['msc_class'] = parse_msc(value)
      elsif hash.key?(key)
        if hash[key].is_a?(Array)
          hash[key] << value
        else
          hash[key] = [hash[key], value]
        end
      else
        hash[key] = value
      end
      hash
    end
    # rubocop:enable Rails/TimeZone, Metrics/PerceivedComplexity,     Metrics/CyclomaticComplexity

    def xml2hash(element)
      return element.texts.map(&:value).join unless element.has_elements?

      result = element.attributes.to_h.transform_values(&:value)
      element.each_element do
        value = xml2hash(it)
        result = merge(result, it.name, value)
      end

      result
    end

    def oai(**)
      require 'oai'
      @oai ||= OAI::Client.new 'https://oaipmh.arxiv.org/oai', http: client
      @oai.list_records(metadata_prefix: 'arXivRaw', set: 'math', **)
    rescue OAI::NoMatchException
      nil
    end

    # rubocop: disable Metrics/ClassLength
    class Paper
      attr_accessor :id, :version, :comment, :authors, :url, :pdf_url,
                    :doi, :doi_url, :category, :categories, :datestamp,
                    :published, :summary, :tags, :title, :updated,
                    :journal_ref, :_debug, :license, :msc_class, :submitter

      ATTR_TRANS = {
        _id: :id,
        entry_id: :id,
        title_type: :_,
        #id: :url,
        _version: :version,
        arxiv_comment: :comment,
        arxiv_journal_ref: :journal_ref,
        comments: :comment,
        abstract: :summary,
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
          from_hash(File.open(file) { JSON.load(it) })
          # rubocop: enable Security/JSONLoad
        end

        def from_db(file)
          res = {}
          require 'sqlite3'
          db = SQLite3::Database.new file
          db.execute('select * from papers') do
            res[row[0]] = new(**JSON.parse(it[1]))
          end
          res
        end

        def from_oai(**)
          oa = Arxiv::Api.oai(**)
          return [] if oa.blank?

          oa.full.each { yield from_oai_item(it), it }
        end

        def from_oai_item(item)
          return unless item.metadata

          pp = new(**Arxiv::Api.xml2hash(item.metadata).values.first)
          pp.datestamp = Date.parse(item.header.datestamp)
          unless pp.authors
            ee = Arxiv::Api.get_by_id(pp.id)
            if ee
              pp.authors = Arxiv::Api.parse_authors(ee.authors)
            else
              warn "Unable to find authors for paper #{pp.id}"
              pp.authors = []
            end
          end
          pp
        end
      end

      def initialize(**attrs)
        attrs.each do |k, v|
          setter = "#{ATTR_TRANS[k.to_sym] || k}="
          #puts "#{setter}#{v.inspect}"
          try(setter, v)
        end
        unless authors
          ee = info_from_arxiv
          if ee
            self.authors = Arxiv::Api.parse_authors(ee.authors)
          else
            warn "Unable to parse authors for paper #{id}"
            self.authors = []
          end
        end
        self._debug = attrs
      end

      def info_from_arxiv
        Arxiv::Api.get_by_id(id)
      end

      def links=(vals)
        vals.each do
          setter = "#{it['title'] || 'abs'}="
          try(setter, it['href'])
        end
      end

      def abs
        URI("#{Arxiv::Api::ARXIV_BASE}/abs/#{id}")
      end

      def pdf
        URI("#{Arxiv::Api::ARXIV_BASE}/pdf/#{id}.pdf")
      end

      def versions
        @versions ||=
          version.respond_to?(:sort) ? version.sort.to_h.values : []
      end

      def submitted
        @submitted ||= if published
          published.is_a?(String) ? Date.parse(published) : published
        else
          versions.first['date']
        end
      end

      def revised
        @revised ||= if updated
          updated.is_a?(String) ? Date.parse(updated) : updated
        else
          versions.last['date']
        end
      end

      def author_names
        return unless authors.respond_to?(:map)

        @author_names ||= authors.map { it.is_a?(Hash) ? it['name'] : it }
      end

      def tag_values
        @tag_values ||= tags&.pluck('term')
      end

      def version_id
        version.respond_to?(:sort) ? version.max.first : "v#{version}"
      end

      def primary
        @primary ||= category || categories.first
      end

      def secondaries
        @secondaries ||=
          (tag_values ? tag_values - aux_tags : categories) - [primary]
      end

      def aux_tags
        @aux_tags ||= tag_values.reject { self.class.arxiv?(it) }
      end
    end
    # rubocop: enable Metrics/ClassLength
    # rubocop: enable Metrics/ModuleLength
  end
end
