require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

class Test::Unit::TestCase
end

# You can use "rake test AR_VERSION=2.0.5" to test against 2.0.5, for example.
# The default is to use the latest installed ActiveRecord.
if ENV["AR_VERSION"]
  gem 'activerecord', "#{ENV["AR_VERSION"]}"
  gem 'activesupport', "#{ENV["AR_VERSION"]}"
end
require 'active_record'
require 'active_support'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'slug'

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"
silence_stream(STDOUT) do
  load(File.dirname(__FILE__) + "/schema.rb")
end

# Used to test slug behavior in general
class Article < ActiveRecord::Base
  slug :headline  
end

# Used to test alternate slug column
class Person < ActiveRecord::Base
  slug :name, :column => :web_slug
end

# Used to test invalid method names
class Company < ActiveRecord::Base
  slug :name
end

# Used to test slugs based on methods rather than database attributes
class Event < ActiveRecord::Base
  slug :title_for_slug
  
  def title_for_slug
    "#{title}-#{location}"
  end
end