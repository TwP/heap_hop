require "optparse"
require "sinatra"

module HeapHop
  class App

    #
    #
    def self.run( args )
      new.parse(args).run
    end

    #
    #
    def initialize
      @heap = nil
      @db   = nil
      @port = 8042
    end

    # Public: Parse the give arguments and store the settings for later.
    #
    # args - The command line arguments as an Array
    #
    # Returns this App instance.
    def parse( args )
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: heap-hop [options]"

        opts.separator "  either a heap or db filename must be given"
        opts.separator ""

        opts.on('-h', '--heap heap', 'Heap') { |heap| @heap = heap }
        opts.on('-d', '--db db', 'Database') { |db| @db = db }

        opts.on('--help', 'Show Help') do
          puts opts
          exit
        end
      end

      parser.parse!(args)

      if @heap.nil? && @db.nil?
        puts parser
        exit 1
      end

      self
    end

    #
    #
    def run
      self
    end
  end
end
