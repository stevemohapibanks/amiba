require 'thor'
require 'thor/group'

module Amiba

  class Util
    def self.in_amiba_application?
      File.exist? ".amiba"
    end
  end

  module Generator

    def self.included(base)
      base.send :include, Thor::Actions
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def source_root(path = nil)
        default_source_root
      end
      
      def default_source_root
        File.dirname(File.expand_path(File.join(__FILE__, "..")))
      end
      
    end
  end

  class Create < Thor::Group
    include Generator
    
    namespace :create
    
    argument :name
    class_option :default_page, :default => "home"

    def create_project_structure
      %w{pages posts layouts}.each {|dirname|
        directory File.join("templates", dirname), File.join(name, dirname)
      }
      create_file(File.join(name, ".amiba"))
    end

    def create_default_page
      require 'amiba/page'
      Amiba::Page::Create.start([options[:default_page]])
    end

  end
end

if Amiba::Util.in_amiba_application?
  require 'amiba/page'
end

