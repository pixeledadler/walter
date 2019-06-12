# frozen_string_literal: true

class Walter
  # Comment
  class Manager
    include Observable
    include Logging
    include State
    include Notifications
    include Actions
    include Requests
    include Messaging::API

    attr_reader :state

    def initialize
      @state = Disabled.new
    end

    # Application Context State Change ----------------------------------------

    def state_change(new_state)
      logger.debug(MANAGER) { "ApplicationContext => #{new_state.class}" }
      case new_state
      when Wilhelm::ApplicationContext::Online
        logger.debug(MANAGER) { 'Enable Manager' }
        enable
      when Wilhelm::ApplicationContext::Offline
        logger.debug(MANAGER) { 'Disable Mananger' }
        disable
      when Wilhelm::UserInterface::Context
        new_state
          .register_service_controllers(
            bluetooth: Walter::UserInterface::Controller::BluetoothController
          )
      when Wilhelm::Notifications
        device_handler = Walter::Manager::Notifications::DeviceHandler.instance
        device_handler.manager = self
        new_state.register_handlers(device_handler)
      end
    end

    # Properties ------------------------------------------------------------

    def devices
      @devices ||= Devices.new
    end
  end
end