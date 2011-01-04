# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
Gem::Specification.new do |s|
  s.name        = "amiba"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steven Mohapi-Banks"]
  s.email       = ["s.mohapi-banks@digital-science.com"]
  s.summary     = "Simple gem to build a static web-site"
  s.description = "Description TBD"
  s.homepage    = "http://www.digital-science.com"
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.files        = Dir.glob("{bin,lib,templates}/**/*") + Dir.glob("templates/**/.empty_directory") + %w{Thorfile Gemfile}
  s.executable   = 'amiba'
  s.require_path = 'lib'
end

