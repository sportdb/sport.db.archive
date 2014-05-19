require './boot'

# make sure connections get closed after every request e.g.
#
#  after do
#   ActiveRecord::Base.connection.close
#  end
#

use ActiveRecord::ConnectionAdapters::ConnectionManagement

run Server
