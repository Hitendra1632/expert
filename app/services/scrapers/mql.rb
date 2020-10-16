if Rails.env.development?
  require 'capybara'
  require 'capybara/poltergeist'
  require 'capybara/rails'
  require 'selenium-webdriver'
  require 'spreadsheet'
end
require 'rest_client'

module Scrapers
  class Mql
    
    def call
      init
      # init_new_sheet
      scrape
    end
    
    private
    
    def init
      Capybara.register_driver :selenium do |app|
        Capybara::Selenium::Driver.new(app, browser: :chrome)
      end
      @session = Capybara::Session.new(:selenium)
      @session.visit 'https://www.mql5.com/en/code/mt4'
    end
    
    def init_new_sheet
      @new_book = Spreadsheet::Workbook.new
      @sheet_num = 0
      @new_book.create_worksheet name: 'schools'
      @row_num = 0
      title_row = %w[id name city]
      @new_sheet = @new_book.worksheet(0)
      @new_sheet.insert_row(0, title_row)
    end
    
    def scrape
      scrape_data
    end
    
    def rating(current_div)
      current_div.find('.rating').find('div')[:class]
    rescue
      ''
    end

    def name(current_div)
      current_div.find('.title').find('a').text
    end

    def description(current_div)
      current_div.find('p').text
    end

    def reference_link(current_div)
      current_div.find('.title').find('a')[:href]
    end
    
    def type(current_div)
      current_div.find('.codeIcon')[:title]
    end
    
    def version
    
    end
    
    def scrape_data
      total_page_count = @session.all('.paginatorEx').first.all('a').last.text.to_i
      (1..169).each do |page_no|
        sleep 3
        puts page_no
        @session.visit "https://www.mql5.com/en/code/mt5/page#{page_no}"
        sleep 3
        code_bases_divs = @session.find('.codebase-list__content').all('.code-tile')
        code_bases_divs.each do |current_div|
          attributes = {
            rating: rating(current_div),
            name: name(current_div),
            description: description(current_div),
            reference_link: reference_link(current_div),
            expert_type: type(current_div),
            version: 'mt5'
          }
          Expert.find_or_create_by(reference_link: attributes[:reference_link]).update(data: attributes)
        end
      end
    end
  end
end