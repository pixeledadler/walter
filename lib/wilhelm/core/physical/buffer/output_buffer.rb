# frozen_string_literal: false

module Wilhelm
  module Core
    # Core::Interface::Buffer::OutputBuffer
    class Interface
      module Buffer
        class OutputBuffer
          def initialize(stream)
            @stream = stream
          end

          def write(string)
            bytes_to_write = string.length
            bytes_written = @stream.write(string)
            bytes_to_write == bytes_written ? true : false
          end

          def write_nonblock(string)
            bytes_to_write = string.length
            bytes_written = @stream.write_nonblock(string)
            bytes_to_write == bytes_written ? true : false
          end
        end
      end
    end
  end
end
