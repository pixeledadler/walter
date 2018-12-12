# frozen_string_literal: true

require 'application/message'
require 'maps/device_map'
require 'maps/command_map'
require 'maps/address_lookup_table'

require 'datalink/frame/indexed_arguments'

require 'datalink/frame/frame_builder'

require 'command/parameter/indexed_bit_array'
require 'command/parameter/base_parameter'

require 'command/builder/base_command_builder'

require 'datalink/packet'

module DataLink
  module LogicalLinkLayer
    # Comment
    class Multiplexer
      include Event
      
      attr_reader :frame_output_buffer, :packet_output_buffer, :write_thread

      def initialize(frame_output_buffer)
        @frame_output_buffer = frame_output_buffer
        @packet_output_buffer = SizedQueue.new(32)
        @threads = ThreadGroup.new
      end

      def name
        self.class.name
      end

      def off
        LOGGER.debug(name) { "#{self.class}#off" }
        close_threads
      end

      def on
        LOGGER.debug(name) { "#{self.class}#on" }
        @write_thread = thread_write_output_frame_buffer(@frame_output_buffer, @packet_output_buffer)
        @threads.add(@write_thread)
        true
      rescue StandardError => e
        LOGGER.error(e)
        e.backtrace.each { |l| LOGGER.error(l) }
        raise e
      end

      def thread_write_output_frame_buffer(frame_output_buffer)
        LOGGER.debug(name) { 'New Thread: Frame Multiplexing' }
        Thread.new do
          Thread.current[:name] = name
          begin
            loop do
              message = packet_output_buffer.pop
              new_frame = multiplex(message)
              LOGGER.unknown(PROG_NAME) { "frame_output_buffer.push(#{new_frame})" }
              frame_output_buffer.push(new_frame)
            end
          rescue StandardError => e
            LOGGER.error(name) { e }
            e.backtrace.each { |l| LOGGER.error(l) }
          end
          LOGGER.warn(name) { "End Thread: Frame Multiplexing" }
        end
      end

      private

      # @return Frame
      def multiplex(message)
        frame_builder = FrameBuilder.new

        frame_builder.from = message.from.d
        frame_builder.to = message.to.d
        frame_builder.command = message.command

        frame = frame_builder.result
        LOGGER.debug('MultiplexingHandler') { "Frame build: #{frame}" }
        frame
      end
    end
  end
end
