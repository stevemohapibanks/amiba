module Amiba
  module Source
    module EntryFinder
      include Amiba::Repo

      def all(args={})
        category = args[:category]
        published = args[:published] || true

        all_entries.map { |cat, name|
          ext = File.extname name
          Amiba::Source::Entry.new(cat, File.basename(name, ext), ext.gsub(/^\./,""))
        }.select {|entry|
          (category == nil || entry.category == category.singularize) &&
          (entry.state == "published" if published )
        }
      end

      protected
      
      def all_entries
        sorted_entries.map do |name|
          name =~ /.*\/(.*)\/(.*)/ ? [$1.singularize.to_sym, $2] : nil
        end.compact
      end

      def sorted_entries
        Dir.glob('entries/*/*').sort do |a,b|
          last_commit_date(a) <=> last_commit_date(b)
        end
      end
    end
  end
end
