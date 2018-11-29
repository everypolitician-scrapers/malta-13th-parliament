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
    noko.css('.table-responsive td').map { |td| fragment(td => Member).to_h }
  end
end

class Member < Scraped::HTML
  # TODO: fetch the member page
  field :id do
    noko.css('a/@href').text.split('/').last
  end

  # TODO: use the date from the other side of the split
  field :sort_name do
    noko.text.split('-').first.tidy
  end

  field :name do
    sort_name.split(', ').reverse.join(' ')
  end

  field :party do
    noko.xpath('preceding::h3').last.text.tidy
  end

  # TODO: get this from the URL
  field :term do
    13
  end
end

url = 'https://www.parlament.mt/en/13th-leg/political-groups/'
Scraped::Scraper.new(url => MembersPage).store(:members)
