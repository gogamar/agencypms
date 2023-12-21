# lib/selenium_helper.rb

require 'selenium-webdriver'

module SeleniumHelper
  def setup_selenium_driver
    driver_path = '/usr/local/bin/chromedriver'
    service = Selenium::WebDriver::Chrome::Service.new(path: driver_path)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    driver = Selenium::WebDriver.for :chrome, options: options, service: service
    return driver
  end
end
