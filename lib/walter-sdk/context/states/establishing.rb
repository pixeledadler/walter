# frozen_string_literal: true

# Top level namespace
module Wolfgang
  class ApplicationContext
    # Wolfgang Service Establishing State
    class Establishing
      include Defaults
      include Constants

      def initialize(context)
        logger.debug(WOLFGANG_EST) { '#initialize' }
        context.register_controls(Vehicle::Controls.instance)
      end

      def open(___)
        logger.debug(WOLFGANG_EST) { '#open' }
        false
      end

      def close(context)
        logger.debug(WOLFGANG_EST) { '#close' }
        logger.debug(WOLFGANG_EST) { 'Stop Notifications' }
        context.notifications&.stop
        logger.debug(WOLFGANG_EST) { 'Disable Mananger' }
        context.manager&.disable
        logger.debug(WOLFGANG_EST) { 'Disable Audio' }
        context.audio&.disable
        logger.debug(WOLFGANG_EST) { 'Disconnect Client.' }
        Client.disconnect
        context.offline!
      end

      def online!(context)
        context.change_state(Online.new)
        # context.manager!
        context.manager.enable
        # context.audio!
        # context.audio.

        context.notifications!
        # context.ui!
        context.alive?
      end

      def offline!(context)
        context.change_state(Offline.new)
      end

      def establishing!(___)
        false
      end

      def ui!(context)
        logger.debug(WOLFGANG_EST) { '#ui' }
        context.ui = context.create_ui(context)
        true
      end

      def manager!(context)
        logger.debug(WOLFGANG_EST) { '#manager' }
        context.manager = context.create_manager(context)
        true
      end

      def audio!(context)
        logger.debug(WOLFGANG_EST) { '#audio' }
        context.audio = context.create_audio(context)
        true
      end

      def alive?(context)
        LogActually.alive.debug(WOLFGANG_EST) { '#alive?' }
        # Client.instance.queue_message('ping', )
        context.ping!(context.reply_block(context))
        true
      end
    end
  end
end
