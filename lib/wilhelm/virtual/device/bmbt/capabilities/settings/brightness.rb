# frozen_string_literal: false

module Wilhelm
  module Virtual
    class Device
      module BMBT
        module Capabilities
          module Settings
            # Settings: LCD Brightness
            module Brightness
              include API
              include Constants
              include Wilhelm::Helpers::Parse

              # NOTE: avoid duplicating brightness constants?

              # Reply Brightness
              # bmbt  gt	  0x06  7F
              def brightness(level)
                lcd_brightness_reply(arguments: bytes(level))
              end
            end
          end
        end
      end
    end
  end
end
