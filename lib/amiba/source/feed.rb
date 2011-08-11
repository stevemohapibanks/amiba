require 'amiba/source'

module Amiba
  module Source
    class Feed
      include Amiba::Source

      attr_accessor :type, :name
      def initialize(fn)
        self.name, self.type = File.basename(fn, ".builder").split(".")
      end

      def filename 
        @filename ||= File.join("feeds", "#{@name}.#{@type}.builder")
      end

      def content=(c)
        @content ||= self.new? ? c : File.read(filename)
      end

      def output_filename
        File.join(Amiba::Configuration.site_dir, "public/#{name}.#{type}")
      end
      alias_method :staged_filename, :filename

      def link
        URI.escape "/#{name}.#{type}"
      end

    end
  end
end
