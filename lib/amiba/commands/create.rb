module Amiba
  module Commands
    class Create < Amiba::Group

      namespace :create

      argument :name
      class_option :path 
      class_option :default_page, :default => "index"

      def init_git
        @repo = Grit::Repo.init(target)
      end

      def create_gitignore
        copy_file File.join("templates",'.gitignore'), File.join(target, '.gitignore')
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

      def create_default_feeds
        directory File.join("templates", "feeds"), File.join(target, "feeds")
      end

      def create_default_page
        inside(target, :verbose => true) do
          invoke(Amiba::Commands::Page::Create,
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
end
