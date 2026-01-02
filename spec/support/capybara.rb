require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.javascript_driver = :selenium_chrome_headless

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers, type: :request
end
