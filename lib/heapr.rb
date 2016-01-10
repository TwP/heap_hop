require 'amalgalite'
require 'multi_json'
require 'oj'

module Heapr

  PATH = File.expand_path("../..", __FILE__).freeze
  LIBPATH = File.join(PATH, "lib").freeze

  def self.path( *args )
    return PATH if args.empty?
    File.join(PATH, *args)
  end

  def self.libpath( *args )
    return LIBPATH if args.empty?
    File.join(LIBPATH, *args)
  end
end

require "heapr/heap_file_parser"
require "heapr/object_store"
require "heapr/version"

