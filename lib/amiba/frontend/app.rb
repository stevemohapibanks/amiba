require 'cgi'
require 'sinatra'
require 'amiba'
require 'mustache/sinatra'

require 'amiba/frontend/views/layout'
require 'amiba/frontend/views/editable'

module Protozoa
  class App < Sinatra::Base
    register Mustache::Sinatra

    include Amiba::Repo

    dir = File.dirname(File.expand_path(__FILE__))

    # We want to serve public assets for now

    set :public,    "#{dir}/public"
    set :static,    true

    set :mustache, {
      # Tell mustache where the Views constant lives
      :namespace => Protozoa,

      # Mustache templates live here
      :templates => "#{dir}/templates",

      # Tell mustache where the views are
      :views => "#{dir}/views"
    }

    # Sinatra error handling
    configure :development, :staging do
      enable :show_exceptions, :dump_errors
      disable :raise_errors, :clean_trace
    end

    configure :test do
      enable :logging, :raise_errors, :dump_errors
    end

    get '/' do
      pull
      @entries = Amiba::Source::Entry.any.all.sort {|a,b| a.category <=> b.category }
      @pages = all_pages
      mustache :index
    end

    get %r{/pages/edit/(.+)\.html$} do
      pull
      @page = Amiba::Source::Page.new(params[:captures][0],"haml")
      @entry = Amiba::Source::PageEntry.new(@page)
      @content = @entry.content
      @name = @page.title
      mustache :edit
    end

    get %r{/pages/(.+)\.html$} do
      @page = Amiba::Source::Page.new(params[:captures][0],"haml")
      @entry = Amiba::Source::PageEntry.new(@page)
      @content = @entry.render
      @name = @page.title
      @editable = true
      mustache :page
    end

    get %r{/entries/edit/(.+?)/(.+)\.html$} do
      pull
      @page = Amiba::Source::Entry.new(params[:captures][0],params[:captures][1],"markdown")
      @content = @page.content
      @name = @page.title
      mustache :edit
    end

    get %r{/entries/(.+?)/(.+)\.html$} do
      @page = Amiba::Source::Entry.new(params[:captures][0],params[:captures][1],"markdown")
      @content = @page.render
      @name = @page.title
      @editable = true
      mustache :page
    end

    post %r{/pages/edit/(.+)\.html$} do
      pull
      @page = Amiba::Source::Page.new(params[:captures][0],"haml")
      @entry = Amiba::Source::PageEntry.new(@page)
      @entry.content = params[:content]
      @entry.save do |filename, file_data|
        File.open(filename, 'w') { |f| f.write(file_data) }
      end
      commit @entry.filename
      push
      redirect "/pages#{@page.link}"
    end

    post %r{/entries/edit/(.+?)/(.+)\.html$} do
      pull
      @page = Amiba::Source::Entry.new(params[:captures][0],params[:captures][1],"markdown")
      @page.content = params[:content]
      @page.author = env["X-DSCI-USER"] || "Anonymous"
      @page.save do |filename, file_data|
        File.open(filename, 'w') { |f| f.write(file_data) }
      end
      commit @page.filename
      push
      redirect "/entries#{@page.link}"
    end

    post '/preview' do
      @name     = "Preview"
      metadata  = {state: "draft", title: params[:title]}
      name      = params[:title].parameterize
      @page     = Amiba::Source::Entry.new(params[:category], name, "markdown", metadata, params[:content])
      @content  = @page.render
      @editable = false
      mustache :page
    end

    get '/entries/create' do
      @name = "New Entry"
      mustache :create
    end

    post '/entries/create' do
      pull
      name = params[:title].parameterize
      metadata  = {state: "published", title: params[:title]}
      @page = Amiba::Source::Entry.new(params[:category], name, "markdown", metadata, params[:content])
      @page.author = env["X-DSCI-USER"] || "Anonymous"
      @page.save do |filename, file_data|
        File.open(filename, 'w') { |f| f.write(file_data) }
      end
      commit @page.filename
      push
      redirect "/entries#{@page.link}"
    end

    get %r{^/(javascript|css|images)} do
      halt 404
    end

    def all_pages
      Dir.glob('pages/**/[^_]*').inject([]) do |acc, page_file|
        if !File.directory? page_file
          page = Amiba::Source::Page.new(File.relpath(page_file, "pages"))
          ent = Amiba::Source::PageEntry.new(page)
          acc << page unless ent.new?
        end
        acc
      end
    end

    def commit_message
      params[:message]
    end

    # dsci specific
    def actor
      Grit::Actor.new(env["X-DSCI-USER"],env["X-DSCI-EMAIL"])
    end

    def commit(filename)
      r = Grit::Repo.new(Dir.pwd)
      r.add(filename)
      r.index.commit(commit_message, nil, actor)
    end

  end
end
