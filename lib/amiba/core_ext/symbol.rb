require 'active_support/inflector/inflections'

class Symbol
  def pluralize
    ActiveSupport::Inflector.pluralize(self.to_s).to_sym
  end

  def singularize
    ActiveSupport::Inflector.singularize(self.to_s).to_sym
  end
end
