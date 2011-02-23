module Amiba
  module Repo

    def init(dir)
      Grit::Repo.init(dir)
    end

    def repo
      @repo ||= Grit::Repo.new(Dir.pwd)
    rescue
      raise "No repo exists at #{Dir.pwd}"
    end

    def add_and_commit(filename, msg=nil)
      repo.add(filename)
      repo.commit_index(msg || "Added a new entry at #{filename}")
    end

    def last_commit_date(filename)
      repo.log(filename).first.committed_date
    end

    def last_commit_dates(*filenames)
      filenames.map {|fn| last_commit_date(fn)}
    end
    
  end
end
