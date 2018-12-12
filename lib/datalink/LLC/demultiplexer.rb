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
    class Demultiplexer
      include Observable
      include ManageableThreads
      include Event

      attr_reader :frame_input_buffer, :packet_input_buffer, :read_thread

      def initialize(frame_input_buffer, address_lookup_table = AddressLookupTable.instance)
        @frame_input_buffer = frame_input_buffer
        @packet_input_buffer = SizedQueue.new(32)
        @address_lookup_table = address_lookup_table
      end

      def on
        LOGGER.debug(name) { '#on' }
        @read_thread = thread_read_input_frame_buffer(@frame_input_buffer, @packet_input_buffer)
        add_thread(@read_thread)
        true
      rescue StandardError => e
        LOGGER.error(e)
        e.backtrace.each { |l| LOGGER.error(l) }
        raise e
      end

      def off
        LOGGER.debug(name) { '#off' }
        close_threads
      end

      private

      def name
        self.class.name
      end

      def thread_read_input_frame_buffer(frame_input_buffer, packet_input_buffer)
        LOGGER.debug(name) { 'New Thread: Frame Demultiplexing' }
        Thread.new do
          Thread.current[:name] = name
          begin
            loop do
              new_frame = frame_input_buffer.pop
              new_packet = demultiplex(new_frame)

              changed
              notify_observers(PACKET_RECEIVED, packet: new_packet)
              
              # LOGGER.unknown(PROG_NAME) { "packet_input_buffer.push(#{new_packet})" }
              # packet_input_buffer.push(new_packet)
            end
          rescue StandardError => e
            LOGGER.error(name) { e }
            e.backtrace.each { |l| LOGGER.error(l) }
          end
          LOGGER.warn(name) { "End Thread: Frame Demultiplexing" }
        end
      end

      def demultiplex(frame)
        from      = frame.from
        from_id   = from.to_i
        from_device = @address_lookup_table.find(from_id)
        LOGGER.debug(name) { "from_device: #{from_device}" }

        to        = frame.to
        to_id     = to.to_i
        to_device   = @address_lookup_table.find(to_id)
        LOGGER.debug(name) { "to_device: #{to_device}" }

        payload   = frame.payload
        LOGGER.debug(name) { "payload: #{payload}" }

        packet = Packet.new(from_device, to_device, payload)
        LOGGER.debug(name) { "Packet build: #{packet}" }
        packet
      end
    end
  end
end
