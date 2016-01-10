require "rubygems" unless defined? Gem
require "bundler"
Bundler.require(:default, :development)

require "minitest/spec"
require "minitest/autorun"
require "minitest/reporters"

# push the lib folder onto the load path
$LOAD_PATH.unshift "lib"
require "heap_hop"

# add custom assertions
#require File.expand_path("../assertions", __FILE__)
#
reporter_options = { color: true, slow_count: 5 }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]
