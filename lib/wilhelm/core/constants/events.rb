# frozen_string_literal: false

module Wilhelm
  module Core
    module Constants
      module Events
        # Channel
        module Channel
          BUS_OFFLINE = :offline
          BUS_ONLINE = :online
          BUS_BUSY = :busy
          BUS_IDLE = :idle
          BUS_ACTIVE = :active
          BYTE_RECEIVED = :byte_received

        end

        # Receiver
        module Receiver
          FRAME_RECEIVED = :frame_received
          FRAME_FAILED = :frame_failed
          FRAME_SENT = :frame_sent
        end

        # top layer?
        module Multiplexing
          MESSAGE_RECEIVED = :message_received
          MESSAGE_SENT = :message_sent
          PACKET_RECEIVED = :packet_received
          PACKET_ROUTABLE = :packet_routable
        end

        # user configuration events
        module Deprecated
          MESSAGE_DISPLAY = :message_display
        end

        # APPLICATION
        module Application
          STATUS_REQUEST = :thread_status_request
          EXIT = :exit
        end

        include Channel
        include Receiver
        include Multiplexing
        include Deprecated
        include Application

        CHANNEL_EVENTS  = [BYTE_RECEIVED, BUS_OFFLINE, BUS_ONLINE, BUS_BUSY, BUS_IDLE, BUS_ACTIVE].freeze
        RECEIVER_EVENTS = [FRAME_RECEIVED, FRAME_FAILED, FRAME_SENT].freeze
        LAYER_EVENTS    = [MESSAGE_RECEIVED, MESSAGE_SENT, PACKET_RECEIVED, PACKET_ROUTABLE].freeze
        USER_EVENTS     = [MESSAGE_DISPLAY].freeze
        APP_EVENTS      = [STATUS_REQUEST, EXIT].freeze

        ALL_EVENTS = (CHANNEL_EVENTS + RECEIVER_EVENTS + LAYER_EVENTS + USER_EVENTS + APP_EVENTS).freeze

        def event_valid?(event)
          ALL_EVENTS.one? { |e| e == event }
        end

        def validate_event(event)
          raise ::ArgumentError, 'unrecognised action' unless event_valid(event)
        end
      end
    end
  end
end
