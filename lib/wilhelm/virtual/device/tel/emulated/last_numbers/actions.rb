# frozen_string_literal: true

module Wilhelm
  module Virtual
    class Device
      module Telephone
        class Emulated < Device::Emulated
          module LastNumbers
            # Device::Telephone::Emulated::LastNumbers::Actions
            module Actions
              include Virtual::Constants::Events::Telephone

              def last_numbers_back!(index:)
                notify_of_action(LAST_NUMBERS_BACK, index: index)
              end

              def last_numbers_forward!(index:)
                notify_of_action(LAST_NUMBERS_FORWARD, index: index)
              end

              private

              def notify_of_action(action, **args)
                logger.unknown(PROC) { "#notify_of_action(#{action}, #{args})" }
                changed
                notify_observers(action, args)
              end
            end
          end
        end
      end
    end
  end
end
