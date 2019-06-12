# frozen_string_literal: true

module Wilhelm
  class ApplicationContext
    # Comment
    module Controls
      include Constants
      include SDK::Controls::Register

      LOGGER_NAME = WILHELM

      CONTROL_REGISTER = {
        BMBT_AUX_HEAT => STATELESS_CONTROL,
        BMBT_OVERLAY => STATELESS_CONTROL,
        BMBT_TEL => STATEFUL_CONTROL
      }.freeze

      CONTROL_ROUTES = {
        BMBT_AUX_HEAT => { load_debug: :stateless },
        BMBT_OVERLAY => { load_audio: :stateless },
        BMBT_TEL => { load_bluetooth: STATEFUL }
      }.freeze

      def load_debug
        logger.debug(LOGGER_NAME) { '#load_debug()' }
        @state.load_debug(self)
      end

      def load_nodes
        logger.debug(LOGGER_NAME) { '#load_nodes()' }
        @state.load_nodes(self)
      end

      def load_services
        logger.debug(LOGGER_NAME) { '#load_services()' }
        @state.load_services(self)
      end

      def load_bluetooth(*args)
        logger.debug(LOGGER_NAME) { "#load_bluetooth(#{args})" }
        @state.load_bluetooth(self, args)
      end

      def load_audio
        logger.debug(LOGGER_NAME) { '#load_audio()' }
        @state.load_audio(self)
      end
    end
  end
end