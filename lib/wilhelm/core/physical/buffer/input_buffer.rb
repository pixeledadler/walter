# frozen_string_literal: false

module Wilhelm
  module Core
    # Core::Interface::Buffer
    class Interface
      module Buffer
        # An extension of a Queue to support multi shifts, and unshifting
        # NOTE this should not handle unshift.... argh.. well.. unshift is framer behaviour..
        # but it's still capsulated with framer.. the actual behaviour of unshift is generic...
        class InputBuffer < SizedQueue
          SIZE = 1024
          def initialize(size = SIZE)
            super(size)
            @unshift_buffer = []
          end

          # Not existing client implemention matches Array#unshift, requirin multiple
          # arguments to be splatted, i.e. buffer.unshift(*my_array)
          def unshift(*objects)
            LOGGER.debug("#{self.class}#unshift(#{objects.size})")
            @unshift_buffer.unshift(*objects)
          end
          
          # def push(args)
          #   super.push(args)
          # end

          def register
            @unshift_buffer.length
          end

          def shift(number_of_bytes = 1)
            # binding.pry
            LOGGER.debug("InputBuffer") { "#shift(#{number_of_bytes})" }
            # raise ::ArgumentError, 'InputBuffer does not support single object shift' if
            #   number_of_bytes <= 1

            shift_result = []

            # Empty unshift buffer before reading IO
            take_unshifted_bytes(shift_result, number_of_bytes) unless @unshift_buffer.empty?

            Array.new(number_of_bytes - shift_result.size).each do |_|
              read_byte = pop
              shift_result.push(read_byte)
            end

            shift_result
          end

          private

          def take_unshifted_bytes(shift_result, number_of_bytes)
            LOGGER.debug("InputBuffer") { "#take_unshifted_bytes(#{number_of_bytes})" }
            LOGGER.debug("InputBuffer") { "#{@unshift_buffer.size} unshifted bytes available." }
            required_bytes = number_of_bytes
            return false if @unshift_buffer.empty?
            until @unshift_buffer.empty? || required_bytes.zero?
              unshifted_byte = @unshift_buffer.shift
              shift_result.push(unshifted_byte)
              required_bytes -= 1
            end
            LOGGER.debug("InputBuffer") { "#{shift_result.size} unshifted bytes taken." }
            true
          end
        end
      end
    end
  end
end
