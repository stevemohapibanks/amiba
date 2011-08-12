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
      @entries = Amiba::Source::Entry.any.all.sort {|a,b| a.category <=> b.category }
      mustache :index
    end

    get %r{/entries/edit/(.+?)/(.+)\.html$} do
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

    post %r{/entries/edit/(.+?)/(.+)\.html$} do
      @page = Amiba::Source::Entry.new(params[:captures][0],params[:captures][1],"markdown")
      @page.content = params[:content]
      @page.save do |filename, file_data|
        File.open(filename, 'w') { |f| f.write(file_data) }
      end
      # add_and_commit @page.filename
      # push
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
      name = params[:title].parameterize
      metadata  = {state: "published", title: params[:title]}
      @page = Amiba::Source::Entry.new(params[:category], name, "markdown", metadata, params[:content])
      @page.save do |filename, file_data|
        File.open(filename, 'w') { |f| f.write(file_data) }
      end
      # add_and_commit @page.filename
      # push
      redirect "/entries#{@page.link}"
    end

    # post '/revert/:page/*' do
    #   wiki  = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
    #   @name = params[:page]
    #   @page = wiki.page(@name)
    #   shas  = params[:splat].first.split("/")
    #   sha1  = shas.shift
    #   sha2  = shas.shift

    #   if wiki.revert_page(@page, sha1, sha2, commit_message)
    #     redirect "/#{CGI.escape(@name)}"
    #   else
    #     sha2, sha1 = sha1, "#{sha1}^" if !sha2
    #     @versions = [sha1, sha2]
    #     diffs     = wiki.repo.diff(@versions.first, @versions.last, @page.path)
    #     @diff     = diffs.first
    #     @message  = "The patch does not apply."
    #     mustache :compare
    #   end
    # end

    # get '/history/:name' do
    #   @name     = params[:name]
    #   wiki      = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
    #   @page     = wiki.page(@name)
    #   @page_num = [params[:page].to_i, 1].max
    #   @versions = @page.versions :page => @page_num
    #   mustache :history
    # end

    # post '/compare/:name' do
    #   @versions = params[:versions] || []
    #   if @versions.size < 2
    #     redirect "/history/#{CGI.escape(params[:name])}"
    #   else
    #     redirect "/compare/%s/%s...%s" % [
    #       CGI.escape(params[:name]),
    #       @versions.last,
    #       @versions.first]
    #   end
    # end

    # get '/compare/:name/:version_list' do
    #   @name     = params[:name]
    #   @versions = params[:version_list].split(/\.{2,3}/)
    #   wiki      = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
    #   @page     = wiki.page(@name)
    #   diffs     = wiki.repo.diff(@versions.first, @versions.last, @page.path)
    #   @diff     = diffs.first
    #   mustache :compare
    # end

    get %r{^/(javascript|css|images)} do
      halt 404
    end

    get %r{/(.+?)/([0-9a-f]{40})} do
      name = params[:captures][0]
      wiki = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
      if page = wiki.page(name, params[:captures][1])
        @page = page
        @name = name
        @content = page.formatted_data
        @editable = true
        mustache :page
      else
        halt 404
      end
    end

    # get '/search' do
    #   @query = params[:q]
    #   wiki = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
    #   @results = wiki.search @query
    #   @name = @query
    #   mustache :search
    # end

    # get '/*' do
      # show_page_or_file(params[:splat].first)
    # end

    def show_page_or_file(name)
      wiki = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
      if page = wiki.page(name)
        @page = page
        @name = name
        @content = page.formatted_data
        @editable = true
        mustache :page
      elsif file = wiki.file(name)
        content_type file.mime_type
        file.raw_data
      else
        @name = name
        mustache :create
      end
    end

    def update_wiki_page(wiki, page, content, commit_message, name = nil, format = nil)
      return if !page ||  
        ((!content || page.raw_data == content) && page.format == format)
      name    ||= page.name
      format    = (format || page.format).to_sym
      content ||= page.raw_data
      wiki.update_page(page, name, format, content.to_s, commit_message)
    end

    def commit_message
      { :message => params[:message] }
    end
  end
end
