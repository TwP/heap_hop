require File.expand_path("../../test_helper", __FILE__)

describe HeapHop::Analyzer do

  before do
    @heap_filename = HeapHop.path("test/data/heap2.json")
    @db_filename   = HeapHop.path("test/data/heap2.sqlite3")
    @analyzer      = HeapHop::Analyzer.new(heap: @heap_filename, db: ":memory:")
  end

  after do
    File.delete(@db_filename) if File.file?(@db_filename)
  end

  describe "when initializing" do
    it "raises an error when no file names are given" do
      assert_raises(ArgumentError) { HeapHop::Analyzer.new }
    end

    it "derives the db file name from the heap file name" do
      analyzer = HeapHop::Analyzer.new(heap: @heap_filename)
      assert_equal @db_filename, analyzer.db_filename
    end

    it "supports differently named db files" do
      assert_equal ":memory:", @analyzer.db_filename
    end

    it "can use a prepared db" do
      # this will create and populate the db file
      analyzer = HeapHop::Analyzer.new(heap: @heap_filename)

      # and now we can open just the db file
      analyzer = HeapHop::Analyzer.new(db: @db_filename)
      refute analyzer.object_store.empty?
    end
  end

  it "returns report classes by name" do
    report = @analyzer.report_class_by_name("generation_object_count")
    assert_equal HeapHop::Reports::GenerationObjectCount, report

    report = @analyzer.report("generation_object_count")
    assert_instance_of HeapHop::Reports::GenerationObjectCount, report
  end

  it "raises an error on unknown reports" do
    assert_raises(ArgumentError) { @analyzer.report "unknown" }
  end

end
