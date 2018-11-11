require 'rubygems'
require 'minitest/autorun'
require 'minitest/reporters'

# You can use "rake test AR_VERSION=2.0.5" to test against 2.0.5, for example.
# The default is to use the latest installed ActiveRecord.
if ENV["AR_VERSION"]
  gem 'activerecord', "#{ENV["AR_VERSION"]}"
end
require 'active_record'

# color test output
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'slug'

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"
load(File.dirname(__FILE__) + "/schema.rb")

require 'models'
