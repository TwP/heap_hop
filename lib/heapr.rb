require 'amalgalite'
require 'multi_json'

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
require "heapr/version"

# SQL tables
#
#   addresses
#     * rowid          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
#     * address        BIGINT NOT NULL,
#     * generation     INTEGER NOT NULL,
#     * obj_type       VARCHAR(16) NOT NULL,
#     * class_address  BIGINT,
#     * file           TEXT,
#     * line           INTEGER,
#     * method         TEXT,
#     * flags          json,
#     * info           json
#
#   references
#     * a    INTEGER NOT NULL REFERENCES(rowid) ON UPDATE CASCADE ON DELETE CASCADE,
#     * b    INTEGER NOT NULL REFERENCES(rowid) ON UPDATE CASCADE ON DELETE CASCADE,
#     * PRIMARY KEY (a, b)
