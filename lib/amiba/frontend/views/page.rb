module Protozoa
  module Views
    class Page < Layout
      attr_reader :content, :page, :footer

      def title
        @page.title
      end

      def format
        @page.format.to_s
      end

      def author
        @page.author
      end

      def date
        @page.pubdate.strftime("%Y-%m-%d %H:%M:%S")
      end
      
      def editable
        @editable
      end
    end
  end
end
