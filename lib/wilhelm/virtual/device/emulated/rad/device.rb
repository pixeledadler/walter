# frozen_string_literal: true

# Comment
class Wilhelm::Virtual
  # Comment
  class SimulatedRadio < EmulatedDevice
    include Capabilities::Radio

    PROC = 'SimulatedRadio'
    SUBSCRIBE = [PING, MENU_GFX].freeze

    def logger
      LogActually.rad
    end

    def subscribe?(command_id)
      SUBSCRIBE.include?(command_id)
    end

    def handle_virtual_receive(message)
      command_id = message.command.d
      return false unless subscribe?(command_id)
      case command_id
      when MENU_GFX
        logger.debug(PROC) { 'Rx: Handling: MENU_GFX' }
        handle_menu_gfx(message.command)
      end

      super(message)
    rescue StandardError => e
      logger.error(PROC) { e }
      e.backtrace.each { |line| logger.error(PROC) { line } }
    end

    def handle_menu_gfx(command)
      case Kernel.format('%8.8b', command.config.value)[7]
      when '1'
        acknowledge_menu
      end
    rescue StandardError => e
      logger.error(PROC) { e }
      e.backtrace.each { |line| logger.error(PROC) { line } }
    end
  end
end
