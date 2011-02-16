module Amiba
  module Source
    module EntryCache

      class << self
        def all(*args)
          category = extract_category!(args)
          
          all_entries.map { |cat, name| Amiba::Source::Entry.new(cat, name, File.extname(name).gsub(/^\./,"")) }
            .select {|entry| category == nil || entry.category == category.to_s}
        end

        protected

        def extract_category!(args)
          args.shift if args.first.is_a?(Symbol)
        end

        def all_entries
          all_entry_files.map do |name|
            name =~ /.*\/(.*)\/(.*)/ ? [$1.singularize.to_sym, $2] : nil
          end.compact
        end
        
        def all_entry_files
          Dir.glob('entries/*/*')
        end
      end

    end
  end
end
