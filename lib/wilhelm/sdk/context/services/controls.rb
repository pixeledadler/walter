# frozen_string_literal: true

module Wilhelm
  module SDK
    class Context
      class ServicesContext
        # Context::Services::Controls
        module Controls
          include Logging
          include Wilhelm::SDK::Controls::Register

          LOGGER_NAME = WILHELM

          CONTROL_REGISTER = {
            BMBT_AUX_HEAT => STATELESS_CONTROL,
            BMBT_MODE => STATELESS_CONTROL,
            BMBT_OVERLAY => STATELESS_CONTROL,
            BMBT_TEL => STATEFUL_CONTROL
          }.freeze

          CONTROL_ROUTES = {
            BMBT_AUX_HEAT => { load_debug: :stateless },
            BMBT_MODE => { load_audio: :stateless },
            BMBT_OVERLAY => { load_now_playing: :stateless },
            BMBT_TEL => { load_manager: STATEFUL }
          }.freeze

          # TODO: these needs to be programatically added by services

          def load_debug
            logger.debug(LOGGER_NAME) { '#load_debug()' }
            @state.load_debug(self)
          end

          def load_services
            logger.debug(LOGGER_NAME) { '#load_services()' }
            @state.load_services(self)
          end

          def load_manager(*args)
            logger.debug(LOGGER_NAME) { "#load_manager(#{args})" }
            @state.load_manager(self, args)
          end

          def load_audio
            logger.debug(LOGGER_NAME) { '#load_audio()' }
            @state.load_audio(self)
          end

          def load_now_playing
            logger.debug(LOGGER_NAME) { '#load_now_playing()' }
            @state.load_now_playing(self)
          end
        end
      end
    end
  end
end
