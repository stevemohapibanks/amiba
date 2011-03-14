class File

  def self.relpath(fn, dir)
    File.join(File.expand_path(fn).split(File::SEPARATOR) - File.expand_path(dir).split(File::SEPARATOR))
  end 

end
