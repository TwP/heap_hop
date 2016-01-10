module HeapHop
  class HeapFileParser
    include Enumerable

    HeapObject = Struct.new \
        :address, :generation, :references, :obj_type, :class_address,
        :file, :line, :method, :flags, :info

    attr_reader :filename

    # Create a new HeapFileParser that can be used to parse the given heap file.
    #
    # filename - The name of the Ruby heap file
    #
    # Raises RuntimeError if the Ruby heap file cannot be found.
    def initialize( filename )
      unless File.file? filename
        raise RuntimeError, "Could not find the heap file: #{filename.inspect}"
      end
      @filename = filename
      @address  = 0
    end

    #
    #
    def each
      return enum_for :each unless block_given?
      @address = 0

      File.open(filename, "r") do |fd|
        fd.each_line do |line|
          yield parse_line(line)
        end
      end

      self
    end

    # Internal: Given a single line from a Ruby heap dump, parse that line of
    # information and return a HeapObject struct.
    #
    # line - A Ruby heap line as a String.
    #
    # Returns a HeapObject.
    def parse_line( line )
      hash = MultiJson.load line

      address       = hash.delete("address")    || next_address
      generation    = hash.delete("generation") || 0
      references    = hash.delete("references")
      obj_type      = hash.delete("type")
      class_address = hash.delete("class")
      file          = hash.delete("file")
      line          = hash.delete("line")
      method        = hash.delete("method")
      flags         = hash.delete("flags")

      address = convert_address(address)
      class_address = convert_address(class_address)
      references.map! { |reference| convert_address(reference) } if references

      HeapObject.new \
        address, generation, references, obj_type, class_address,
        file, line, method, flags, hash
    end

    # Internal: Convert a memory address to an Integer value.
    #
    # Returns an Integer or `nil`
    def convert_address( address )
      return address if address.nil? || address.is_a?(Integer)
      address.to_i(16)
    end

    # Internal: Returns the next pseudo-memory address. This is used for heap
    # objects that do not have a memory addres - the VM root is one of these.
    def next_address
      current_address, @address = @address, @address+1
      return current_address
    end
  end
end
