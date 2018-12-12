# frozen_string_literal: true

# Comment
class DataLinkListener < BaseListener
  # name = self.class.name

  def initialize(interface_handler)
    @interface_handler = interface_handler
  end

  def name
    self.class.name
  end

  def update(action, properties = {})
    # CheapLogger.datalink.unknown(name) { "#update(#{action}, #{properties})" }
    case action
    when BUS_OFFLINE
      bus_offline(action, properties)
    end
  rescue StandardError => e
    CheapLogger.datalink.error(name) { e }
    e.backtrace.each { |l| CheapLogger.datalink.error(l) }
  end

  private

  def bus_offline(action, properties)
    # CheapLogger.datalink.warn(name) { 'Bus Offline!' }
    @interface_handler.update(action, properties)
  end
end
