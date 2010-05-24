require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  require 'authlogic/test_case'
  require 'machinist/active_record'
  require 'sham'
  require 'faker'
end

Spork.each_run do
  # This code will be run each time you run your specs.
  if in_memory_database?
    puts "Setting up in memory database"
    old_stdout = $stdout
    $stdout = open('/dev/null','w')
    load "#{Rails.root}/db/schema.rb"
    $stdout.close
    $stdout = old_stdout
  end
  Dir[File.expand_path('../blueprints/*.rb',__FILE__)].each {|f| require f}
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting


  # Add more helper methods to be used by all tests here...
end
