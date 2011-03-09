module Amiba
  module Source
    module EntryFinder
      
      def method_missing(method_name, *args, &block)
        proxy = FinderProxy.new
        proxy.send(method_name, *args, &block)
      rescue
        raise ArgumentError.new("#{method_name} does not exist")
      end
      
    end

    class FinderProxy
      include Amiba::Repo
      include Enumerable

      def each
        entries.each {|entry| yield entry}
      end

      def first
        entries.first
      end

      def last
        entries.last
      end

      def count
        entries.count
      end

      def [](index)
        entries[index]
      end

      def entries
        result = (scopes[:category] || CategoryScope.new).apply
        result = (scopes[:state] || StateScope.new).apply(result)
        result = scopes[:offset].apply(result) if scopes[:offset]
        result = scopes[:limit].apply(result) if scopes[:limit]
        result.sort do |a, b|
          last_commit_date(a.filename) <=> last_commit_date(b.filename)
        end
      end

      [:draft, :published, :any].each do |state|
        define_method state do
          self[:state] = StateScope.new(state)
          self
        end
      end

      def method_missing(method_name, *args, &block)
        entry_types = (Dir.glob('entries/*') << "all").map {|c| File.basename(c).to_sym}
        if entry_types.include?(method_name)
          self[:category] = CategoryScope.new(method_name)
        else
          raise ArgumentError
        end
        self
      end

      def offset(index)
        self[:offset] = OffsetScope.new(index)
        self
      end
      
      def limit(count)
        self[:limit] = LimitScope.new(count)
        self
      end

      protected
      
      def []=(key, val)
        scopes[key] = val
        self
      end

      def scopes
        @scopes ||= {}
      end

    end

    class CategoryScope
      include Amiba::Repo
      def initialize(category = :all)
        @category = category
      end
      def apply
        entry_files.map do |ef|
          _, category, filename = ef.split('/')
          name, format = filename.split('.')
          Amiba::Source::Entry.new(category, name, format)
        end
      end
      def entry_files
        globstring = "entries/#{@category == :all ? '*' : @category.to_s}/*"
        Dir.glob(globstring).select {|e| !repo.log(e).empty?}
      end
    end
    
    class StateScope
      def initialize(state = :published)
        @state = state
      end
      def apply(entries)
        return entries if @state == :any
        entries.select {|e| e.state.to_sym == @state}
      end
    end

    class OffsetScope
      def initialize(offset = 0)
        @offset = offset
      end
      def apply(entries)
        entries[@offset..-1]
      end
    end
      
    class LimitScope
      def initialize(limit = -1)
        @limit = (limit == -1 ? -1 : limit - 1)
        end
      def apply(entries)
        entries[0..@limit]
      end
    end
  end
end
