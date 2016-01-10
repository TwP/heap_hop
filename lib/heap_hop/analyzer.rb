require "pathname"

module HeapHop
  class Analyzer

    attr_reader :heap_file

    #
    # filename - The Ruby heap file name as a String.
    #
    def initialize( filename )
      @heap_file = filename

      path = Pathname.new @heap_file
      db_filename = File.join(path.dirname, path.basename(path.extenstion)) + ".db"

      @store = ObjectStore.new(db_filename)
      load_object_store
    end

    #
    #
    def load_object_store( force: false )
      @store.purge! if force

      if @store.empty?
        parser = HeapFileParser.new(heap_file)
        parser.each_slice(100) { |ary| @store.insert(ary) }
      end

      self
    end
  end
end
