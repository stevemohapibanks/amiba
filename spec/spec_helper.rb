require 'rubygems'
require 'fileutils'
require 'bundler/setup'

Bundler.require(:default, :development)

require 'amiba'
require 'amiba/all'
require 'factories'

RSpec.configure do |config|
  config.include(RspecTagMatchers)
  config.around do |example|
    tmp_dir = Dir.mktmpdir
    Grit::Repo.init tmp_dir
    FileUtils.cp('templates/.amiba', tmp_dir)
    Dir.chdir tmp_dir, &example
    FileUtils.rm_rf tmp_dir
  end
end
