# frozen_string_literal: true

require 'scraped'

class MembersPage < Scraped::HTML
  field :members do
    column(1).each { |mem| mem[:category] = 'Government' } +
      column(2).each { |mem| mem[:category] = 'Opposition' }
  end

  private

  def column(column)
    noko.css('.column2 table td[%d]' % column)
        .select { |cell| cell.attr('bgcolor') == '#f3f3f3' }
        .map(&:text)
        .map(&:tidy)
        .reject(&:empty?)
        .map { |name| { name: name.split(' - ').first } }
  end
end
