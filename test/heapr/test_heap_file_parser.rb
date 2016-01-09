require File.expand_path("../../test_helper", __FILE__)

describe Heapr::HeapFileParser do
  before do
    filename = Heapr.path("test/data/heap1.json")
    @parser = Heapr::HeapFileParser.new(filename)
  end

  it "returns an enumerator" do
    enumerator = @parser.each
    assert enumerator.instance_of?(Enumerator)
  end

  it "iterates over all lines in the heap file" do
    count = 0
    @parser.each { |obj| count += 1 }
    assert_equal 37512, count
  end

  it "parses a single heap dump line" do
    line = %q/{"type":"ROOT","root":"vm","references":["0x7f8c718c7710"]}/
    obj = @parser.parse_line(line)

    assert_equal 0, obj.address
    assert_equal 0, obj.generation
    assert_equal [140241177179920], obj.references
    assert_equal "ROOT", obj.obj_type
    assert_nil obj.class_address
    assert_nil obj.file
    assert_nil obj.line
    assert_nil obj.method
    assert_nil obj.flags
    assert_equal({"root" => "vm"}, obj.info)

    line = %q/{"address":"0x7f8c71a45768","type":"HASH","generation":3,"class":"0x7f8c718dd8f8","size":2,"references":["0x7f8c71a456a0","0x7f8c71a450b0"],"memsize":200,"flags":{"wb_protected":true}}/
    obj = @parser.parse_line(line)

    assert_equal 140241178744680, obj.address
    assert_equal 3, obj.generation
    assert_equal [140241178744480, 140241178742960], obj.references
    assert_equal "HASH", obj.obj_type
    assert_equal 140241177270520, obj.class_address
    assert_nil obj.file
    assert_nil obj.line
    assert_nil obj.method
    assert_equal({"wb_protected" => true}, obj.flags)
    assert_equal({"size" => 2, "memsize" => 200}, obj.info)
  end

  it "generates a psuedo-address" do
    assert_equal 0, @parser.next_address
    assert_equal 1, @parser.next_address
    assert_equal 2, @parser.next_address
    assert_equal 3, @parser.next_address
  end

  it "converts memory addresses to integers" do
    assert_nil @parser.convert_address(nil)
    assert_equal 1234, @parser.convert_address(1234)
    assert_equal 140241194875720, @parser.convert_address("0x7f8c729a7b48")
  end
end
