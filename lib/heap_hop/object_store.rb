module HeapHop
  class ObjectStore

    attr_reader :db

    def initialize( filename )
      @db = Amalgalite::Database.new(filename)
      create_tables! unless has_table?("heap_objects")
    end

    def tables
      db.schema.tables.keys
    end

    #
    #
    def has_table?( name )
      tables.include? name
    end

    # Returns `true` if there are not objects in the `heap_objects` SQL table.
    def empty?
      results = db.execute <<-SQL
        SELECT COUNT(*) FROM 'heap_objects';
      SQL
      results.first.first == 0
    end

    # Public: Primary method for inserting heap objects into the SQLite
    # datastore.
    #
    # heap_objects - An Array of HeapObjects from the heap file parser
    #
    # Returns this object store.
    def insert( heap_objects )
      heap_objects = [heap_objects] unless heap_objects.is_a? Array
      insert_heap_objects(heap_objects)
      insert_references(heap_objects)
      self
    end

    # Public: Remove all heap object entries from the SQLite tables.
    #
    # Returns this object store.
    def purge!
      db.transaction do |transaction|
        transaction.execute("DELETE FROM 'heap_objects'")
        transaction.execute("DELETE FROM 'references'")
      end
      self
    end

    # Internal: Populate the `heap_objects` table for the given array of heap
    # objects.
    #
    # heap_objects - An Array of HeapObjects from the heap file parser
    #
    # Returns the results of the SQL transaction.
    def insert_heap_objects( heap_objects )
      sql = <<-SQL
        INSERT INTO 'heap_objects' ('address', 'generation', 'obj_type', 'class_address', 'file', 'line', 'method', 'memsize', 'flags', 'info')
        VALUES (:address, :generation, :obj_type, :class_address, :file, :line, :method, :memsize, json(:flags), json(:info))
      SQL

      db.transaction do |transaction|
        transaction.prepare(sql) do |statement|
          heap_objects.each do |obj|
            params = {
              ":address"       => obj.address,
              ":generation"    => obj.generation,
              ":obj_type"      => obj.obj_type,
              ":class_address" => obj.class_address,
              ":file"          => obj.file,
              ":line"          => obj.line,
              ":method"        => obj.method,
              ":memsize"       => obj.memsize,
              ":flags"         => MultiJson.dump(obj.flags),
              ":info"          => MultiJson.dump(obj.info)
            }
            statement.execute(params)
          end
        end
      end
    end

    # Internal: Populate the `references` table for the given array of heap
    # objects.
    #
    # heap_objects - An Array of HeapObjects from the heap file parser
    #
    # Returns the results of the SQL transaction.
    def insert_references( heap_objects )
      sql = <<-SQL
        INSERT INTO 'references' ('a', 'b') VALUES (:a, :b)
      SQL

      db.transaction do |transaction|
        transaction.prepare(sql) do |statement|
          heap_objects.each do |obj|
            address    = obj.address
            references = obj.references
            next if references.nil? || references.empty?

            references.uniq.each do |reference|
              statement.execute({":a" => address, ":b" => reference})
            end
          end
        end
      end
    end

    #
    #
    def create_tables!
      db.transaction do |transaction|
        transaction.execute <<-SQL
          CREATE TABLE 'heap_objects' (
            'address'        BIGINT PRIMARY KEY NOT NULL,
            'generation'     INTEGER NOT NULL,
            'obj_type'       TEXT NOT NULL,
            'class_address'  BIGINT,
            'file'           TEXT,
            'line'           INTEGER,
            'method'         TEXT,
            'memsize'        INTEGER,
            'flags'          TEXT,
            'info'           TEXT
          );
        SQL

        transaction.execute <<-SQL
          CREATE TABLE 'references' (
            'a' INTEGER NOT NULL REFERENCES 'heap_objects' ('address') ON UPDATE CASCADE ON DELETE CASCADE,
            'b' INTEGER NOT NULL REFERENCES 'heap_objects' ('address') ON UPDATE CASCADE ON DELETE CASCADE,
            PRIMARY KEY ('a', 'b')
          );
        SQL

        transaction.execute <<-SQL
          CREATE INDEX 'heap_objects_generation_idx' ON 'heap_objects' ('generation');
        SQL

        transaction.execute <<-SQL
          CREATE INDEX 'heap_objects_obj_type_idx' ON 'heap_objects' ('obj_type');
        SQL

        transaction.execute <<-SQL
          CREATE INDEX 'references_a_idx' ON 'references' ('a');
        SQL

        transaction.execute <<-SQL
          CREATE INDEX 'references_b_idx' ON 'references' ('b');
        SQL
      end

      self
    end
  end
end
