require "optparse"
require "sinatra/base"

module HeapHop
  class App < Sinatra::Base

    get "/" do
      content_type :text
      "Hello There! - #{analyzer.inspect}"
    end

    def analyzer
      self.class.analyzer
    end

    def self.run( args )
      options = parse(args)
      analyze_heap(options)
      run!(options)
    end

    def self.analyze_heap( options )
      print "Analyzing heap ..."
      @analyzer = Analyzer.new(heap: options[:heap], db: options[:db])
      puts " done!"
      self
    rescue RuntimeError => err
      puts " #{err.message}"
      exit 1
    end

    def self.analyzer
      @analyzer
    end

    # Parse the give arguments and store the settings for later.
    #
    # args - The command line arguments as an Array
    #
    # Returns this App instance.
    def self.parse( args )
      options = {
        heap: nil,
        db:   nil,
        port: 8042
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: heap-hop [options]"

        opts.separator "  either a heap or db filename must be given"
        opts.separator ""

        opts.on('-h', '--heap heap', 'Heap') { |heap| options[:heap] = heap }
        opts.on('-d', '--db db', 'Database') { |db| options[:db] = db }
        opts.on('-p', '--port port', 'Port', Integer) { |port| options[:port] = port }

        opts.on('--help', 'Show Help') do
          puts opts
          exit
        end
      end

      parser.parse!(args)

      if options[:heap].nil? && options[:db].nil?
        puts parser
        exit 1
      end

      options
    end
  end
end
