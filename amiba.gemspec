# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
Gem::Specification.new do |s|
  s.name        = "amiba"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steven Mohapi-Banks"]
  s.email       = ["s.mohapi-banks@digital-science.com"]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{bin,lib,templates}/**/*") + %w{Thorfile}
  s.require_path = 'lib'
end
