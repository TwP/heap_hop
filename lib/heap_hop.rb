require "amalgalite"
require "multi_json"
require "oj"

module HeapHop

  PATH = File.expand_path("../..", __FILE__).freeze
  LIBPATH = File.join(PATH, "lib").freeze

  # Returns the path for HeapHop. If any arguments are given,
  # they will be joined to the end of the path using `File.join`.
  #
  # Returns a String.
  def self.path( *args )
    return PATH if args.empty?
    File.join(PATH, *args)
  end

  # Returns the library path for HeapHop. If any arguments are given,
  # they will be joined to the end of the library path using `File.join`.
  #
  # Returns a String.
  def self.libpath( *args )
    return LIBPATH if args.empty?
    File.join(LIBPATH, *args)
  end
end

require "heap_hop/analyzer"
require "heap_hop/app"
require "heap_hop/heap_file_parser"
require "heap_hop/object_store"
require "heap_hop/version"
require "heap_hop/reports"
