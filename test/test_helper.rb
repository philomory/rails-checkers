require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  #require 'authlogic/test_case'
  require 'machinist/active_record'
  require 'sham'
  require 'faker'
  ActiveRecord::Base.clear_active_connections!
end

Spork.each_run do
  Dir[File.expand_path('../blueprints/*.rb',__FILE__)].each {|f| require f}
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting


  # Add more helper methods to be used by all tests here...
end
