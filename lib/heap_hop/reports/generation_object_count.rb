module HeapHop
  module Reports
    class GenerationObjectCount

      attr_reader :raw_results
      attr_reader :counts

      def initialize(results)
        @raw_results = results
        @counts = results.each_with_object({}) do |row, acc|
          acc[row["generation"]] = row["count"]
        end
      end

      def generation_count
        counts.size
      end

      def generation(g)
        counts[g]
      end

      def self.call(db)
        results = db.execute(<<-SQL)
          SELECT generation, COUNT(*) AS 'count'
          FROM heap_objects
          GROUP BY generation
          ORDER BY generation ASC
        SQL
        new(results)
      end
    end
  end
end
