
ENV['RACK_ENV'] ||= 'development'

puts "ENV['RACK_ENV'] = #{ENV['RACK_ENV']}"

require 'bundler'

# ruby core n stdlibs
require 'json'
require 'uri'
require 'logger'
require 'pp'

# 3rd party gems via bundler (see Gemfile)
Bundler.setup
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

# Database Setup & Config

db_config = {
  adapter:  'sqlite3',
  database: 'football.db'     # NOTE: change to use your db of choice (e.g. worldcup.db, bundesliga.db, ski.db etc.)
}

pp db_config
ActiveRecord::Base.establish_connection( db_config )

## for debugging - disable for production use
ActiveRecord::Base.logger = Logger.new( STDOUT )


require './server.rb'
