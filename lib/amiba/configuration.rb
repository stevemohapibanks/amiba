require 'active_support/hash_with_indifferent_access'

module Amiba
  class Configuration

    class << self

      def method_missing(name, *args, &block)
        raise ArgumentError if args.length > 1
        if name[-1] == '='
          write_setting(name[0..-2].to_sym, args[0])
        else
          read_setting(name)
        end
      end

      protected

      def load_defaults
        defaults = YAML.load(File.read('.amiba'))
        @config.merge!(defaults)
      end

      def write_setting(name, value)
        config[name] = value
      end

      def read_setting(name)
        config[name]
      end

      def config
        return @config unless @config.nil?
        @config = HashWithIndifferentAccess.new
        load_defaults
        @config
      end
    end
  end
end
