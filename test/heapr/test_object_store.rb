require File.expand_path("../../test_helper", __FILE__)

describe Heapr::ObjectStore do
  before do
    # use an in-memory SQLite DB
    @store = Heapr::ObjectStore.new ":memory:"
  end

  it "automatically creates tables" do
    assert @store.has_table?("heap_objects")
    assert @store.has_table?("references")
  end

end
