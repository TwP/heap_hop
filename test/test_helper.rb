require "rubygems" unless defined? Gem
require "bundler"
Bundler.require(:default, :development)

require "minitest/spec"
require "minitest/autorun"

# push the lib folder onto the load path
$LOAD_PATH.unshift "lib"
require "heapr"

# add custom assertions
#require File.expand_path("../assertions", __FILE__)

