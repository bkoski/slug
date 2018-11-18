require File.join(File.dirname(__FILE__), 'slug', 'slug')

if defined?(ActiveRecord)
  ActiveRecord::Base.instance_eval { extend Slug::ClassMethods }
end

if defined?(Rails) && Rails.version.to_i < 3
  raise "This version of slug requires Rails 3 or higher"
end