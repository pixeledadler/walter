# frozen_string_literal: true

module Wilhelm
  module Virtual
    class Device
      module MFL
        class Augmented < Device::Augmented
          module State
            # Comment
            module Sent
              # 0x3B
              def handle_mfl_func_button(command)
                logger.debug(moi) { "MFL_FUNC -> #{command.pretty}" }
                return mode!(command.mode?) if command.rt?
                notify_of_button(command)
              end

              # 0x32
              def handle_mfl_vol_button(command)
                logger.debug(moi) { "MFL_VOL -> #{command.pretty}" }
                notify_of_button(command)
              end

              private

              def notify_of_button(command)
                changed
                notify_observers(:button, button: command.button, state: command.state, source: :mfl)
              end
            end
          end
        end
      end
    end
  end
end