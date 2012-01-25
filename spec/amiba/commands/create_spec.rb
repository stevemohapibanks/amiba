require 'spec_helper'

describe Amiba::Commands::Create do

  it "should create a new directory with the project name" do
    Amiba::Commands::Create.start(["test"])
    Dir.exists?("test").should be_true
  end

  it "should create the .amiba file" do
    Amiba::Commands::Create.start(["test"])
    File.exists?("test/.amiba").should be_true
  end

  it "should initialise a new git repo" do
    Amiba::Commands::Create.start(["test"])
    Dir.exists?(".git").should be_true
  end

  it "should create the project structure" do
    Amiba::Commands::Create.start(["test"])
    Dir.exists?("test/entries").should be_true
    Dir.exists?("test/pages").should be_true
    Dir.exists?("test/layouts").should be_true
    Dir.exists?("test/public/js").should be_true
    Dir.exists?("test/public/css").should be_true
    Dir.exists?("test/public/images").should be_true
    Dir.exists?("test/feeds").should be_true
  end
end
