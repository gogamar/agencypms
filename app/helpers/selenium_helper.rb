# lib/selenium_helper.rb

require 'selenium-webdriver'

# for local development

# module SeleniumHelper
#   def setup_selenium_driver
#     driver_path = '/usr/local/bin/chromedriver'
#     service = Selenium::WebDriver::Chrome::Service.new(path: driver_path)
#     options = Selenium::WebDriver::Chrome::Options.new
#     options.add_argument('--headless')
#     driver = Selenium::WebDriver.for :chrome, options: options, service: service
#     return driver
#   end
# end

# for Heroku deployment

module SeleniumHelper
  def setup_selenium_driver
    # No need to specify the driver path on Heroku
    service = Selenium::WebDriver::Chrome::Service.new
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    driver = Selenium::WebDriver.for :chrome, options: options, service: service
    return driver
  end
end
