# frozen_string_literal: true

module Wilhelm
  module Virtual
    class Device
      module Telephone
        class Emulated < Device::Emulated
          # Device::Telephone::Emulated::Received
          module Received
            include Constants

            # 0x02 PONG
            # Piggyback off the radio announce to annunce
            def handle_pong(message)
              return false unless message.from?(:gfx)
              return false unless message.command.status.value == ANNOUNCE
              logger.info(PROC) { "GFX has announced. Piggybacking (sic)" }
              ready
              true
            end

            # 0x20 TEL-OPEN
            def handle_tel_open(message)
              logger.debug(PROC) { '#handle_tel_open' }
              generate_top_8
            end

            # 0x31 INPUT
            def handle_input(command)
              # @note filter HOLD and RELEASE
              return false unless press?(command)
              logger.unknown(PROC) { '#handle_input(command)' }

              case command.source.value
              when SOURCE_RECENT
                false
              when SOURCE_INFO
                false
              when SOURCE_DIAL
                if [FUNCTION_SOS, FUNCTION_NAVIGATE].include?(command.function.value)
                  dial_clear
                end
              when SOURCE_DIRECTORY
                if [FUNCTION_SOS, FUNCTION_NAVIGATE].include?(command.function.value)
                  directory_clear
                end
              when SOURCE_TOP_8
                if [FUNCTION_SOS, FUNCTION_NAVIGATE].include?(command.function.value)
                  top_8_clear
                end
              end

              # @todo use source to work out when to clear

              case command.function.value
              when FUNCTION_RECENT
                # delegate_contact
              when FUNCTION_CONTACT
                delegate_contact(command.source, command.action)
              when FUNCTION_DIGIT
                delegate_dial(command.action)
              when FUNCTION_SOS
                delegate_sos
              when FUNCTION_NAVIGATE
                delegate_navigation(command.action)
              when FUNCTION_INFO
                delegate_function_info
              end
            end

            private

            def button_id(action)
              action.parameters[:button_id].value
            end

            def button_state(action)
              action.parameters[:button_state].value
            end

            def press?(command)
              button_state(command.action) == INPUT_PRESS
            end

            def delegate_contact(source, action)
              logger.unknown(PROC) { "#delegate_contact(#{action})" }
              index = button_id(action)
              logger.unknown(PROC) { FUNCTIONS[FUNCTION_CONTACT][index] }

              case source.value
              when SOURCE_DIRECTORY
                directory_name("Directory. #{FUNCTIONS[FUNCTION_CONTACT][index]}")
              when SOURCE_TOP_8
                top_8_name("Top 8. #{FUNCTIONS[FUNCTION_CONTACT][index]}")
              end
            end

            def delegate_dial(action)
              logger.unknown(PROC) { "#delegate_dial(#{action})" }
              index = button_id(action)
              logger.unknown(PROC) { FUNCTIONS[FUNCTION_DIGIT][index] }
              return dial_number_remove if index == ACTION_REMOVE
              dial_number(FUNCTIONS[FUNCTION_DIGIT][index])
            end

            def delegate_sos
              logger.unknown(PROC) { "#delegate_sos" }
              logger.unknown(PROC) { FUNCTIONS[FUNCTION_SOS][ACTION_SOS_OPEN] }
              open_sos
            end

            def delegate_navigation(action)
              logger.unknown(PROC) { "#delegate_navigation(#{action})" }
              index = button_id(action)
              case index
              when ACTION_DIAL_OPEN
                logger.unknown(PROC) { FUNCTIONS[FUNCTION_NAVIGATE][ACTION_DIAL_OPEN] }
                open_dial
              when ACTION_SMS_OPEN
                logger.unknown(PROC) { FUNCTIONS[FUNCTION_NAVIGATE][ACTION_SMS_OPEN] }
              when ACTION_DIR_OPEN
                logger.unknown(PROC) { FUNCTIONS[FUNCTION_NAVIGATE][ACTION_DIR_OPEN] }
                generate_directory
              else
              end
            end

            def delegate_function_info
              logger.unknown(PROC) { "#delegate_function_info" }
              logger.unknown(PROC) { FUNCTIONS[FUNCTION_INFO][ACTION_INFO_OPEN] }
              open_info
            end

            # @deprecated
            def ready
              logger.warn(PROC) { '#ready is deprecated!' }
              logger.debug(PROC) { 'Telephone ready macro!' }
              leds(:off)
              leds!
              power!(OFF)
              status!
              announce
              sleep(0.25)
              power!(ON)
              status!
              # tel_led(LED_ALL)
              # bluetooth_pending
            end

            # @deprecated
            def tel_state(telephone_state = TEL_OFF)
              logger.warn(PROC) { '#tel_state is deprecated!' }
              status(status: telephone_state)
            end
          end
        end
      end
    end
  end
end
