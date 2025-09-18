# frozen_string_literal: true

require 'feedjira'

module Feedjira
  module Parser
    class AtomArxivAuthor
      include SAXMachine

      element :name, as: :name
      element 'arxiv:affiliation', as: :affiliation
    end

    class AtomArxivEntry < AtomEntry
      element 'arxiv:primary_category', as: :category, value: :term
      element 'arxiv:comment', as: :comment
      element 'arxiv:journal_ref', as: :journal_ref
      element 'arxiv:doi', as: :doi
      element :link, as: :doi_url, value: :href, with: { title: 'doi' }
      element :link, as: :url, value: :href, with: { type: 'text/html' }
      element :link, as: :pdf_url, value: :href, with: { title: 'pdf' }
      elements :author, as: :authors, class: AtomArxivAuthor
    end

    class AtomArxiv
      include SAXMachine
      include FeedUtilities

      element :title
      element :id, as: :query_id
      element :updated, as: :updated, class: Time
      element :link, as: :feed_url, value: :href, with: { rel: 'self' }
      element 'opensearch:totalResults', as: :totalResults, class: Integer
      element 'opensearch:startIndex', as: :startIndex, class: Integer
      element 'opensearch:itemsPerPage', as: :itemsPerPage, class: Integer
      elements :entry, as: :entries, class: AtomArxivEntry

      def self.able_to_parse?(xml)
        #%r{<feed[^>]+xmlns\s?=\s?["'](https?://www\.w3\.org/2005/Atom|http://purl\.org/atom/ns\#)["'][^>]*>} =~ xml.encode('UTF-8', invalid: :replace)
        xml.encode('UTF-8', invalid: :replace)&.include?('xmlns:arxiv')
      end

      def self.preprocess(xml)
        Preprocessor.new(xml).to_xml
      end

      def url
        @url || (links - [feed_url]).last
      end
    end
  end
end

Feedjira.configure do
  it.parsers.unshift Feedjira::Parser::AtomArxiv
end
