require File.expand_path("../../test_helper", __FILE__)

describe HeapHop::ObjectStore do
  before do
    # use an in-memory SQLite DB
    filename = HeapHop.path("test/data/heap1.json")
    @parser = HeapHop::HeapFileParser.new(filename)
    @store = HeapHop::ObjectStore.new ":memory:"
  end

  it "automatically creates tables" do
    assert @store.has_table?("heap_objects")
    assert @store.has_table?("references")
  end

  it "adds a heap object to the SQLite database" do
    line = %q/{"address":"0x7f8c71a45768","type":"HASH","generation":3,"class":"0x7f8c718dd8f8","size":2,"references":["0x7f8c71a456a0","0x7f8c71a450b0"],"memsize":200,"flags":{"wb_protected":true}}/
    obj = @parser.parse_line(line)

    assert_equal 0, count("SELECT COUNT(*) FROM 'heap_objects'")
    assert_equal 0, count("SELECT COUNT(*) FROM 'references'")

    @store.insert obj

    assert_equal 1, count("SELECT COUNT(*) FROM 'heap_objects'")
    assert_equal 2, count("SELECT COUNT(*) FROM 'references'")
  end

  it "populates from a parsed heap dump" do
    @parser.each.each_slice(100) { |ary| @store.insert(ary) }

    assert_equal 37512, count("SELECT COUNT(*) FROM 'heap_objects'")
    assert_equal 74729, count("SELECT COUNT(*) FROM 'references'")
  end

  def count( sql )
    results = @store.db.execute(sql)
    results.first.first
  end
end
