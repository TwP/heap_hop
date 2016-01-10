module HeapHop
  module Reports
    class GenerationObjectCount

      attr_reader :raw_results
      attr_reader :counts

      def initialize(results)
        @raw_results = results
        @counts = results.each_with_object({}) { |row, acc|
          acc[row["generation"]] = row["count"]
        }
      end

      def generation_count
        counts.size
      end

      def generation(g)
        counts[g]
      end

      def self.call(db)
        results = db.execute(<<-SQL)
        SELECT generation
              ,count(*) as count
          FROM heap_objects
      GROUP BY generation
      ORDER BY generation ASC
        SQL
        new(results)
      end
    end
  end
end
