# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
Gem::Specification.new do |s|
  s.name        = "amiba"
  s.version     = "0.0.6"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steven Mohapi-Banks"]
  s.email       = ["s.mohapi-banks@digital-science.com"]
  s.summary     = "Simple gem to build a static web-site"
  s.description = "Description TBD"
  s.homepage    = "http://www.digital-science.com"
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.files        = Dir.glob("{bin,lib,templates}/**/*") + Dir.glob("templates/**/.empty_directory") + %w{Thorfile templates/.amiba}
  s.executable   = 'amiba'
  s.require_path = 'lib'

  s.add_dependency('thor',          '~> 0.14.6')
  s.add_dependency('tilt',          '~> 1.2.1')
  s.add_dependency('haml',          '~> 3.0.25')
  s.add_dependency('activesupport', '~> 3.0.4')
  s.add_dependency('activemodel',   '~> 3.0.4')
  s.add_dependency('i18n',          '~> 0.5.0')
  s.add_dependency('rdiscount',     '~> 1.6.8')
  s.add_dependency('fog',           '>= 0.6.0')
  s.add_dependency('grit',          '~> 2.4.1')

  s.add_development_dependency("rspec")
  s.add_development_dependency("rspec_tag_matchers")
  s.add_development_dependency("autotest")
  s.add_development_dependency("factory_girl", ">=2.0.0.beta1")
end

