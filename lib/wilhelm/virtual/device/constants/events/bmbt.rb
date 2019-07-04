# frozen_string_literal: false

module Wilhelm
  module Virtual
    module Constants
      module Events
        # Virtual::Device::BMBT Events
        module BMBT
          # Input related events
          module Input
            # Generic event used for any buttons- button specifics are handled
            # by the observers
            BMBT_BUTTON = :button

            INPUTS = constants.map { |i| const_get(i) }
          end

          include Input

          def input?(event)
            INPUTS.include?(event)
          end
        end
      end
    end
  end
end
