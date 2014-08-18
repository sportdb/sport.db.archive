
require './config/boot'

Rack::Handler::Thin.run StarterApp.new, :Port => 9292

