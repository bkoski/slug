require File.join(File.dirname(__FILE__), 'slug', 'slug')

ActiveRecord::Base.instance_eval { include Slug }
if defined?(Rails) && Rails.version.to_i < 4
  raise "This version of slug requires Rails 4 or higher"
end
