# frozen_string_literal: true

require 'notifications/notification_listener'
require 'notifications/notification_handler'
# require 'notifications/messaging_queue'
# require 'notifications/subscriber'

# Comment
class Notifications
  include Singleton

  attr_reader :listener, :handler

  def self.start(bus)
    instance.start(bus)
  end

  def start(bus)
    return false if started?
    @listener = NotificationListener.new(Subscriber)
    @handler = NotificationHandler.new(bus)
    listener.handler = handler
    listener.listen
  end

  def started
    @started = true
  end

  def started?
    @started ? true : false
  end
end
