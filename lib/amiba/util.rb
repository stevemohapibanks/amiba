module Amiba

  class Util
    def self.in_amiba_application?
      File.exist? ".amiba"
    end
  end

end
