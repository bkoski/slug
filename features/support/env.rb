$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'slug'

require 'test/unit/assertions'

require 'test/unit/assertions'

World do |world|
  
  world.extend(Test::Unit::Assertions)
  
  world
end
