require File.expand_path("../../../test_helper", __FILE__)

describe HeapHop::Reports::GenerationObjectCount do
  before do
    # use an in-memory SQLite DB
    filename = HeapHop.path("test/data/heap1.json")
    @parser  = HeapHop::HeapFileParser.new(filename)
    @store   = HeapHop::ObjectStore.new ":memory:"

    @store.insert( @parser.each.take(1000) )
    @db = @store.db
  end

  it "calculates the counts by generation" do
    counts = ::HeapHop::Reports::GenerationObjectCount.call(@db)
    assert_equal(16, counts.generation_count)
    assert_equal(7, counts.generation(8))
  end
end
