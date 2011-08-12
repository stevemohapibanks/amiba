require 'amiba'
require 'amiba/frontend/app'
require 'rack/auth/dscildap'

use Rack::Auth::DsciLdap
run Protozoa::App.new
