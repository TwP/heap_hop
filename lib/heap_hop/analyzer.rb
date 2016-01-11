require "pathname"

module HeapHop
  class Analyzer

    BATCH_SIZE = 300

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
    # name - A report name as a String.
    #
    # Raises an ArgumentError if the report name is invalid.
    def report( name )
      clazz = report_class_by_name(name)
      clazz.call(db)
    rescue NameError
      raise ArgumentError, "Unkonwn report: #{name.inspect}"
    end

    # Internal:
    #
    # name - A report name as a String.
    #
    # Returns the report class.
    # Raises a NameError if the class does not exist.
    def report_class_by_name( name )
      string = name.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
      string.gsub!(/\//, '::')

      HeapHop::Reports.const_get(string)
    end

    # Returns the name of the SQLite DB file as a String.
    def db_filename
      return @db_filename unless @db_filename.nil?

      path = Pathname.new heap_filename
      @db_filename = File.join(path.dirname, path.basename(path.extname)) + ".sqlite3"
    end

    # Public: Parse the heap file and load all the heap objects and their
    # references into the SQLite DB.
    #
    # force - A boolean flag used to force loading data into the SQLite DB.
    #
    # Returns this analyzer instance.
    def load_object_store( force: false )
      object_store.purge! if force

      if object_store.empty?
        parser.each.each_slice(BATCH_SIZE) { |ary| object_store.insert(ary) }
      end

      self
    end

    # Public: Determine if the SQLite DB is up-to-date with the heap file data.
    # So if the heap file has been modified after the SQLite DB file, then it is
    # not up to date.
    #
    # Returns `true` or `false`.
    def up_to_date?
      heap_time = heap_file_exists? ? File.mtime(heap_filename) : nil
      db_time   = db_file_exists?   ? File.mtime(db_filename)   : nil

      if heap_time && db_time
        heap_time < db_time    # is the DB newer than the heap file
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

    # Internal: Accessor the heap file parser. A new parser is returned each
    # time this method is called.
    #
    # Returns the HeapFileParser
    def parser
      HeapHop::HeapFileParser.new(heap_filename)
    end

    # Internal: Accessor for the object store.
    #
    # Returns the ObjectStore.
    def object_store
      @object_store ||= HeapHop::ObjectStore.new(db_filename)
    end

    # Internal: Accessor the SQLite DB handle.
    #
    # Returns the SQLite database.
    def db
      object_store.db
    end
  end
end
