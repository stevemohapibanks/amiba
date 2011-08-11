require 'cgi'

module Protozoa
  module Views
    class Layout < Mustache
      include Rack::Utils
      alias_method :h, :escape_html

      attr_reader :name

      def escaped_name
        CGI.escape(@name)
      end

      def title
        "Home"
      end

      def edit_url
        if @page.class == Amiba::Source::Entry
          "/entries/edit#{@page.link}"
        else
          "/pages/edit#{@page.link}"
        end
      end

    end
  end
end
