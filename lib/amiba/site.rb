module Amiba
  module Site

    class Generate < Thor::Group
      include Amiba::Generator

      namespace :"site:generate"
    end
  end
end
