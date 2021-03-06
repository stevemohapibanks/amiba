require 'fog'
require 'webrick'

module Amiba
  module Site

    class Editor < Thor::Group
      include Amiba::Generator

      namespace :"site:editor"
      class_option :port, :default => 4567

      def edit
        require 'amiba/frontend/app'
        Protozoa::App.run!(options)
      end
    end
    class Preview < Thor::Group
      include Amiba::Generator

      namespace :"site:preview"
      class_option :port, :default => 4321

      def create
        invoke Amiba::Site::Generate
      end

      def preview
        root = File.expand_path(File.join(Amiba::Configuration.site_dir, "public"))
        logger = WEBrick::Log.new($stderr, WEBrick::Log::ERROR)
        server = WEBrick::HTTPServer.new({:Port => options[:port], :DocumentRoot => root, :Logger => logger})

        ['INT', 'TERM'].each {|signal| 
          trap(signal) {server.shutdown}
        }

        say ""
        say ""
        say "Preview available at http://localhost:#{options[:port]}/"
        say "To end, press Ctrl+C"

        server.start
      end
    end

    class S3Upload < Thor::Group
      include Amiba::Generator
      include Amiba::Repo

      namespace :"site:upload:s3"

      class_option :credentials, :default => :default
      class_option :target, :default => "site"

      def init_s3
        cf = File.expand_path(File.join(Dir.pwd, ".fog"))
        Fog.credentials_path = cf if File.exists? cf
        Fog.credential = options[:credentials].to_sym
        @s3 ||= Fog::Storage.new(:provider=>'AWS')
      end

      def create
        invoke Amiba::Site::Generate
      end

      def configure_s3
        if ! @s3.directories.get bucket 
          @bucket = @s3.directories.create(:key=>bucket, :public=>true, :location=>location)
          say_status "Created", @bucket.key, :green
          @s3.put_bucket_website(bucket,"index.html")
          say_status "Configured", @bucket.key, :green
        else
          @bucket = @s3.directories.get bucket 
        end
      end

      def upload_files
        Dir[File.join(Amiba::Configuration.site_dir, "public", "**/*")].each do |ent|
          next if File.directory? ent
          path = File.expand_path ent
          name = File.relpath(path, File.join(Amiba::Configuration.site_dir, "public"))
          data = File.open path
          file = @bucket.files.create(:key=>name, :body=>data, :public=>true)
          say_status "Uploaded", name, :green
        end
      end

      def git_push
        push
        say_status "Changes pushed to git", "", :green
      end

      def complete
        host = "http://#{bucket}.s3-website-#{Fog.credentials[:region]}.amazonaws.com/"
        say_status "Available at", host, :green
      end

      private
      def bucket
        Amiba::Configuration.send(:"#{options[:target]}_name")
      end

      def location
        Amiba::Configuration.s3_location || "EU"
      end

    end

    class Generate < Thor::Group
      include Amiba::Generator

      namespace :"site:generate"
      class_option :drafts, :default => false

      def self.source_root
        Dir.pwd
      end

      def cleardown
        remove_dir Amiba::Configuration.site_dir
        remove_dir Amiba::Configuration.staged_dir
      end

      def create_site_structure
        empty_directory Amiba::Configuration.site_dir
      end
      
      def copy_favicon
        if File.exists? "public/images/favicon.ico"
          copy_file "public/images/favicon.ico", File.join(Amiba::Configuration.site_dir, "public/favicon.ico")
        end
      end

      def copy_xdomain
        if File.exists? "public/crossdomain.xml"
          copy_file "public/crossdomain.xml", File.join(Amiba::Configuration.site_dir, "public/crossdomain.xml")
        end
      end

      def copy_javascript
        directory "public/js", File.join(Amiba::Configuration.site_dir, "public/js")
      end

      def copy_images
        directory "public/images", File.join(Amiba::Configuration.site_dir, "public/images")
      end
      
      def copy_css
        Dir.glob('public/css/*.css').each do |css_file|
          copy_file css_file, File.join(Amiba::Configuration.site_dir, "public/css/", File.basename(css_file))
        end
      end
      
      def process_and_copy_sass
        Dir.glob('public/css/[^_]*.scss').each do |scss_file|
          create_file File.join(Amiba::Configuration.site_dir,"public/css/", File.basename(scss_file).gsub('scss', 'css')) do
            Amiba::Tilt.new(scss_file).render
          end
        end
      end
    
      def build_entries
        Amiba::Source::Entry.send(state).each do |entry|
          build_page entry
        end
      end

      def build_pages
        Dir.glob('pages/**/[^_]*').each do |page_file|
          next if File.directory? page_file
          page = Amiba::Source::Page.new(File.relpath(page_file, "pages"))
          next unless (page.state == "published" || options[:drafts])
          build_page page
        end
      end

      def build_json
        Dir.glob('entries/*').each do |cat|
          next unless File.directory? cat
          c = File.basename cat
          create_file(File.join(Amiba::Configuration.site_dir, "public", c, "latest.json")) do
            Amiba::Source::Entry.send(c.to_sym.pluralize).limit(20).each.inject([]) do |acc, ent|
              a = ent.metadata
              a["content"] = ent.render
              acc << a
            end.to_json
          end
        end
      end

      def build_feeds
        Dir.glob('feeds/*.builder').each do |feed_file|
          feed = Amiba::Source::Feed.new(feed_file)
          begin
            create_file(feed.output_filename) do
              Amiba::Tilt.new(feed.filename).render(Amiba::Scope.new(feed), :xml => Builder::XmlMarkup.new)
            end
          rescue
            say_status "Failed", "Unable to process #{feed.name}: #{$!}, skipping", :red
          end
        end
      end

      private

      def state
        if options[:drafts]
          :any
        else
          :published
        end
      end

      def build_layout(page)
        layout = Amiba::Source::Layout.new(page.layout)
        # Fall back to the default layout if we can't find the requested one
        if layout.new?
          layout = Amiba::Source::Layout.new("default")
        end
        layout
      end

      def build_page(page)
        layout = build_layout(page)
        begin
          create_file(page.output_filename) do
            Amiba::Tilt.new(layout, :smartypants=>true).render(Amiba::Scope.new(page))
          end
        rescue
          say_status "Failed", "Unable to process #{page.name}: #{$!}, skipping", :red
        end
      end

    end
  end
end
