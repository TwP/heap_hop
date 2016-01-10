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

    def has_table?( name )
      tables.include? name
    end

    def stupid
      db.execute <<-SQL
        WITH RECURSIVE transitive_closure(a, b, distance, path_string) AS
        ( SELECT a, b, 1 AS distance,
            a || '.' || b || '.' AS path_string
          FROM 'references'
          UNION ALL
          SELECT tc.a, e.b, tc.distance + 1,
          tc.path_string || e.b || '.' AS path_string
          FROM 'references' AS e
            JOIN transitive_closure AS tc
              ON e.a = tc.b
          WHERE tc.path_string NOT LIKE '%' || e.b || '.%'
        )
        SELECT * FROM transitive_closure
        ORDER BY a, b, distance;
      SQL
    end

    def insert_heap_objects( heap_objects )
      heap_objects = [heap_objects] unless heap_objects.is_a? Array

      sql = <<-SQL
        INSERT INTO 'heap_objects' ('address', 'generation', 'obj_type', 'class_address', 'file', 'line', 'method', 'flags', 'info')
        VALUES (:address, :generation, :obj_type, :class_address, :file, :line, :method, json(:flags), json(:info))
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
              ":flags"         => MultiJson.dump(obj.flags),
              ":info"          => MultiJson.dump(obj.info)
            }
            transaction.execute(sql, params)
          end
        end
      end

      self
    end

    def insert_references( heap_objects )
      heap_objects = [heap_objects] unless heap_objects.is_a? Array

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
              transaction.execute(sql, {":a" => address, ":b" => reference})
            end
          end
        end
      end

      self
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
