require 'amiba'
require 'amiba/configuration'
require 'amiba/source'
require 'amiba/page'
require 'amiba/entry'

RSpec.configure do |config|
  config.around do |example|
    Dir.chdir(File.join(File.dirname(__FILE__), 'test_app'), &example)
  end
end
