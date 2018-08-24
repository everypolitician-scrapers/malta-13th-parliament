#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class MembersPage < Scraped::HTML
  field :members do
    noko.css('.table-responsive td').map { |td| fragment td => Member }
  end
end

class Member < Scraped::HTML
  # TODO: fetch the member page
  field :id do
    noko.css('a/@href').text.split('/').last
  end

  # TODO: use the date from the other side of the split
  field :name do
    noko.text.split('-').first.tidy
  end

  field :party do
    noko.xpath('preceding::h4').last.text.tidy
  end
end

def scraper(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

start = 'https://www.parlament.mt/en/13th-leg/political-groups/'
data = scraper(start => MembersPage).members.map { |mem| mem.to_h.merge(term: 13) }

data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']
ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[name term], data)
