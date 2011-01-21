require 'amiba'
require 'amiba/configuration'
require 'amiba/scope'
require 'amiba/source'
require 'amiba/page'
require 'amiba/entry'

RSpec.configure do |config|
  config.around do |example|
    Dir.chdir(File.join(File.dirname(__FILE__), 'test_app'), &example)
  end
end

#require 'capybara/rspec'
require 'rspec_tag_matchers'
  
RSpec.configure do |config|
  config.include(RspecTagMatchers)
end
