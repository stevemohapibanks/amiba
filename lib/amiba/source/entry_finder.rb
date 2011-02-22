module Amiba
  module Source
    module EntryFinder

      def all(args={})
        category = args[:category]
        state = args[:published] || "published"

        all_entries.map do |cat, name|
          ext = File.extname name
          Amiba::Source::Entry.new(cat, File.basename(name, ext), ext.gsub(/^\./,""))
        end.select {|entry| (category == nil || entry.category == category.singularize) && (state == "any" || entry.state == state) }
      end

      protected
      
      def all_entries
        all_entry_files.map do |name|
          name =~ /.*\/(.*)\/(.*)/ ? [$1.singularize.to_sym, $2] : nil
        end.compact
      end

      def sorted_entries
        repo = Grit::Repo.new('.')
        all_entry_files.sort do |a,b|
          repo.log(b).first.committed_date <=> repo.log(a).first.committed_date
        end
      end
      
      def all_entry_files
        Dir.glob('entries/*/*')
      end
    end
  end
end
