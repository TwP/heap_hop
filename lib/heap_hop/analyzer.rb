require "pathname"

module HeapHop
  class Analyzer

    BATCH_SIZE = 100

    attr_reader :heap_filename

    #
    # heap - The Ruby heap file name as a String.
    # db   - The SQLite database file name as a String.
    #
    def initialize( heap: nil, db: nil )
      if heap.nil? && db.nil?
        raise ArgumentError, "either a `heap` filename or a `db` filename must be given"
      end

      @heap_filename = heap
      @db_filename   = db

      if up_to_date?
        load_object_store
      else
        load_object_store(force: true)
      end
    end

    #
    #
    def db_filename
      return @db_filename unless @db_filename.nil?

      path = Pathname.new heap_filename
      @db_filename = File.join(path.dirname, path.basename(path.extname)) + ".sqlite3"
    end

    #
    #
    def load_object_store( force: false )
      object_store.purge! if force

      if object_store.empty?
        parser.each.each_slice(BATCH_SIZE) { |ary| object_store.insert(ary) }
      end

      self
    end

    #
    #
    def up_to_date?
      heap_time = heap_file_exists? ? File.mtime(heap_filename) : nil
      db_time   = db_file_exists?   ? File.mtime(db_filename)   : nil

      if heap_time && db_time
        heap_time < db_time
      elsif db_file_exists?
        true
      else
        false
      end
    end

    # Returns `true` if the heap file exists on disk.
    def heap_file_exists?
      heap_filename && File.file?(heap_filename)
    end

    # Returns `true` if the SQLite DB file exists on disk.
    def db_file_exists?
      db_filename && File.file?(db_filename)
    end

    # Internal:
    #
    # Returns the HeapFileParser
    def parser
      HeapHop::HeapFileParser.new(heap_filename)
    end

    # Internal:
    #
    # Returns the ObjectStore.
    def object_store
      @object_store ||= HeapHop::ObjectStore.new(db_filename)
    end

    # Internal:
    #
    # Returns the SQLite database.
    def db
      object_store.db
    end
  end
end
