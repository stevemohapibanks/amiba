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
    class_option :path 
    class_option :default_page, :default => "home"

    def init_git
      @repo = Grit::Repo.init(target)
    end
    
    def create_gemfile
      copy_file 'Gemfile', File.join(target, 'Gemfile')
    end

    def create_project_structure
      copy_file File.join('templates', '.amiba'), File.join(target, ".amiba")
      %w{entries pages layouts}.each {|dirname|
        directory File.join("templates", dirname), File.join(target, dirname)
      }
    end

    def create_assets_structure
      %w{public/js public/css public/images}.each do |dirname|
        empty_directory File.join(target, dirname)
      end
    end
    
    def create_default_page
      require 'amiba/page'
      inside(target, :verbose => true) do
        invoke(Amiba::Page::Create,
               [options[:default_page]],
               :title => name.titleize,
               :description => "#{name.titleize} Homepage. Please change this to be more descriptive")
      end   
    end

    def commit_to_git
      Dir.chdir(@repo.working_dir) do
        @repo.add %w{.amiba Gemfile layouts pages}
        @repo.commit_all("Initial commit of #{name} project.")
      end
    end

    private

      def target
        if options[:path]
          File.expand_path(File.join(options[:path], name))
        else
          name
        end
      end

  end
end


