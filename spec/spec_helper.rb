require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, :development)

require 'amiba'
require 'amiba/configuration'
require 'amiba/scope'
require 'amiba/source'
require 'amiba/page'
require 'amiba/entry'

require 'factories'

RSpec.configure do |config|
  config.include(RspecTagMatchers)
  config.around do |example|
    Dir.chdir(File.join(File.dirname(__FILE__), 'test_app'), &example)
  end
end
