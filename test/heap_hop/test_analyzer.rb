require File.expand_path("../../test_helper", __FILE__)

describe HeapHop::Analyzer do

  describe "when initializing" do
    it "raises an error when no file names are given" do
      assert_raises(ArgumentError) { HeapHop::Analyzer.new }
    end
  end
end
