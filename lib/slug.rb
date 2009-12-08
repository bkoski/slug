require File.join(File.dirname(__FILE__), 'slug', 'slug')
require File.join(File.dirname(__FILE__), 'slug', 'ascii_approximations')

if defined?(ActiveRecord)
  ActiveRecord::Base.instance_eval { extend Slug::ClassMethods }
end