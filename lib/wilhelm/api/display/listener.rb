# frozen_string_literal: true

module Wilhelm
  module API
    class Display
      # API::Display::Listener
      module Listener
        include Constants::Events

        NAME = 'Display Listener'

        def update(event, properties = {})
          # logger.debug(NAME) { "#update(#{event}, #{properties})" }
          return update_control(event, properties) if control?(event)
          return update_state(event, properties) if state?(event)
          return update_cache(event, properties) if cache?(event)
        end

        private

        # CACHE
        def update_cache(event, properties = {})
          case event
          when HEADER_CACHE
            header_cache(properties)
          when HEADER_WRITE
            header_write(properties)
          when MENU_CACHE
            menu_cache(properties)
          when MENU_WRITE
            menu_write(properties)
          end
        end

        # STATE
        def update_state(event, properties = {})
          case event
          when GT_MONITOR_ON
            logger.debug(NAME) { "#update(#{GT_MONITOR_ON})" }
            monitor_on
          when GT_MONITOR_OFF
            logger.debug(NAME) { "#update(#{GT_MONITOR_OFF})" }
            monitor_off
          when CODE_ON
            logger.debug(NAME) { "#update(#{CODE_ON})" }
            code_on
          when CODE_OFF
            logger.debug(NAME) { "#update(#{CODE_OFF})" }
            code_off
          when PROG_ON
            logger.unknown(NAME) { "#update(#{PROG_ON})" }
            prog_on
          when PROG_OFF
            logger.unknown(NAME) { "#update(#{PROG_OFF})" }
            prog_off
          when GT_PING
            logger.debug(NAME) { "#update(#{GT_PING})" }
            ping
          when GT_ANNOUNCE
            logger.debug(NAME) { "#update(#{GT_ANNOUNCE})" }
            announce
          when GT_OBC
            logger.debug(NAME) { "#update(#{GT_OBC}, #{properties})" }
            obc_request
          when GT_AUX
            logger.debug(NAME) { "#update(#{GT_AUX}, #{properties})" }
            aux_request
          when GT_SETTINGS
            logger.debug(NAME) { "#update(#{GT_SETTINGS}, #{properties})" }
            settings_request
          when KL_30
            logger.debug(NAME) { "#update(#{KL_30}, #{properties})" }
            kl_30
          when KL_R
            logger.debug(NAME) { "#update(#{KL_R}, #{properties})" }
            kl_r
          when KL_15
            logger.debug(NAME) { "#update(#{KL_15}, #{properties})" }
            kl_15
          end
        end

        # CONTROL
        def update_control(event, properties = {})
          case event
          when GT_CONTROL
            logger.debug(NAME) { "#update(#{GT_CONTROL}, #{properties})" }
            data_select(properties)
          when BMBT_CONTROL
            logger.debug(NAME) { "#update(#{BMBT_CONTROL}, #{properties})" }
            handle_control(properties)
          when MFL_CONTROL
            logger.debug(NAME) { "#update(#{MFL_CONTROL}, #{properties})" }
            handle_control(properties)
          end
        end
      end
    end
  end
end
