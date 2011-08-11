require 'tilt'

module Amiba
  class Tilt

    def self.new(obj, options={}, &block)
      if obj.is_a?(String) && File.exist?(obj)
        ::Tilt.new(obj, options)
      else
        if template_class = ::Tilt[obj.filename]
          block ||= proc { obj.content }
          template_class.new(obj.filename, nil, options, &block)
        else
          raise "Can't find a template loader!"
        end
      end
    end
  end
end
