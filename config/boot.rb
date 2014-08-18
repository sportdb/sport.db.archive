# encoding: utf-8

############################################
# 3rd party gems via bundler (see Gemfile)

require 'bundler'
Bundler.setup    ## will setup $LOAD_PATH to get locked down gem version (see Gemfile.lock)

require 'pp'     ## fyi: pp is pretty printer

puts '$LOAD_PATH:'
pp $LOAD_PATH


#######################################################
# some more ruby core n stdlibs (NOT bundled in gems)
require 'json'
require 'yaml'
require 'uri'
require 'logger'


############################
## require 3rd party gems

ENV['RACK_ENV'] ||= 'development'
puts "RACK_ENV=#{ENV['RACK_ENV']}"

require 'sinatra/base'    ## note: sinatra will pull in web server (e.g. rack)


require 'sportdb'    ## note: sportdb will pull in db access (e.g. activerecord)


############################
# database setup n config

DB_CONFIG = YAML.load_file( './config/database.yml' )

pp DB_CONFIG
ActiveRecord::Base.establish_connection( DB_CONFIG[ENV['RACK_ENV']] ) ## note: assumes 'development'


## for debugging - disable for production use
ActiveRecord::Base.logger = Logger.new( STDOUT )


require './app'

