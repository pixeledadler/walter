require 'observer'

require 'message'
require 'event'

require 'handlers/display_handler'
require 'handlers/session_handler'
require 'handlers/data_logging_handler'

require 'maps/device_map'
require 'maps/command_map'

# TODO this needs to be changed later. I've just chucked everything in a single
# listener for now, but if I can define a standard event notification, i can
# from the single notify_observers(args) call, ensure that the arguments are
# global.
# If the events are universal, i avoid coupling the outcome to event definition
# i.e. don't have statistic events, have events that the statslistener attaches to

# NOTE there's no.. events.. per se, it's... states..
class GlobalListener
  include Observable
  include Event

  def initialize(application_layer)
    # TODO split out
    @stream_logging = nil
    @stats = initialize_stats
    @session_handler = SessionHandler.instance
    @display_handler = DisplayHandler.instance
    @data_logging_handler = DataLoggingHandler.instance

    @device_map = DeviceMap.instance
    @command_map = CommandMap.instance

    @application_layer = application_layer
    add_observer(self)
  end

  def update(action, properties)
    # LOGGER.debug("[Listener] #{self.class}#update(#{action}, #{properties})")
    raise ::ArgumentError, 'unrecognised action' unless valid?(action)

    begin
      case action
      when EXIT
        LOGGER.warn "[Global Listener] Exiting! Reason: #{properties[:reason]}"
        LOGGER.warn "[Global Listener] Hiding display output..."
        # hide the message output as it clutters the exit log messages
        @display_handler.update(EXIT, properties)
        LOGGER.warn "[Global Listener] Closing log files..."
        @data_logging_handler.update(action, properties)
      when BUS_ONLINE
        LOGGER.info("[Global Listener] BUS online!")
        @data_logging_handler.update(action, properties)
      when BUS_OFFLINE
        LOGGER.warn("[Global Listener] BUS offline!")
        @data_logging_handler.update(action, properties)
      when BYTE_RECEIVED
        update_stats(BYTE_RECEIVED)
        @data_logging_handler.update(action, properties)
      when FRAME_VALIDATED
        update_stats(FRAME_VALIDATED)
        @data_logging_handler.update(action, properties)
        message = process_frame(properties[:frame])

        changed
        notify_observers(MESSAGE_RECEIVED, message: message)
      when FRAME_FAILED
        update_stats(FRAME_FAILED)
      when MESSAGE_RECEIVED
        update_stats(MESSAGE_RECEIVED)
        @session_handler.update(MESSAGE_RECEIVED, properties)
        @display_handler.update(MESSAGE_RECEIVED, properties)
        @application_layer.new_message(properties[:message])
      else
        LOGGER.debug("#{self.class} erm.. #{action} wasn't handled?")
      end
    rescue Exception => e
      LOGGER.error("#{self.class} Exception: #{e}")
      e.backtrace.each { |l| LOGGER.error(l) }
      binding.pry
    end
  end

  private

  # ************************************************************************* #
  #                                  HANDLERS
  # ************************************************************************* #

  # ------------------------------ STATISTICS ------------------------------ #

  # TODO split out
  METRICS = [BYTE_RECEIVED, FRAME_VALIDATED, FRAME_FAILED, MESSAGE_RECEIVED]

  def initialize_stats
    METRICS.map do |metric|
      [metric, 0]
    end.to_h
  end

  def update_stats(metric)
    @stats[metric] += 1
  end

  # ------------------------------ FRAME ------------------------------ #

  MESSAGE_COMPONENTS = [:from, :to, :command, :arguments].freeze
  FRAME_TO_MESSAGE_MAP = {
    from: { frame_component: :header,
            component_index: 0 },
    to: { frame_component: :tail,
          component_index: 0 },
    command: {  frame_component: :tail,
                component_index: 1 },
    arguments: { frame_component: :tail,
                 component_index: 2..-2 } }.freeze

  def process_frame(frame)
    LOGGER.debug("#{self.class}#process_frame(#{frame})")
    LOGGER.debug frame.inspect

    # FRAME = HEADER, PAYLOAD, FCS
    # MESSAGE = FROM, TO, COMMAND, ARGUMENTS

    from = frame.header[0]
    from = from.to_d
    from = @device_map.find(from)

    to = frame.tail[0]
    to = to.to_d
    to = @device_map.find(to)

    arguments = frame.tail[2..-2]

    command = frame.tail[1]
    command_id = command.to_d
    command = @command_map.find(command_id, arguments)

    Message.new(from, to, command, arguments)
  end
end
