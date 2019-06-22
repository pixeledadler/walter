# frozen_string_literal: false

module Wilhelm
  module Virtual
    class Device
      module Diagnostics
        module Capabilities
          module Lighting
            def any(to, *args)
              vehicle_control(to: to, arguments: array(args))
            end

            BYTE_1 = {
              0x00 => :always
            }

            BYTE_2 = {
              0b1000_0000 => :unknown,
              0b0100_0000 => :unknown,
              0b0010_0000 => :unknown,
              0b0001_0000 => :emergency,
              0b0000_1000 => :unknown,
              0b0000_0100 => :high_on,
              0b0000_0010 => :unknown,
              0b0000_0001 => :unknown
            }

            BYTE_3 = {
              0b1000_0000 => :indicate_left,
              0b0100_0000 => :indicate_right,
              # this is the first time I've seen command 0x5C (LAMP2)
              0b0010_0000 => :test_x,
              0b0001_0000 => :fog_rear,
              0b0000_1000 => :nothing,
              # i saw emergy flash?
              0b0000_0100 => :nothing,
              # everything lit up like lights came on?
              0b0000_0010 => :flash_interior,
              # i saw external lights flash
              0b0000_0001 => :flash_exterior
            }.freeze

            BYTE_4 = {
              # not sure but triggered engine failafe warn...?
              0b1000_0000 => :unknown,
              0b0100_0000 => :unknown,
              0b0010_0000 => :unknown,
              # i did below first... but looked similar
              # different combination of lamp on, and different lamp2 values...
              0b0001_0000 => :text_x,
              # looked similar to above... LAMP2 was returning
              # lcm    glo_l   LAMP2? 0x97 (1001 0111)
              # lcm    glo_l   LAMP2? 0x8a (1000 1010)
              # lcm    glo_l   LAMP2? 0x7e (0111 1110)
              # lcm    glo_l   LAMP   (0000 0011) LOW [ON] Parking [ON]
              # gfx    lcm     LAMP-REQ        --
              # lcm    glo_l   LAMP   (0000 0011) LOW [ON] Parking [ON]
              # lcm    glo_l   LAMP   (0000 0011) LOW [ON] Parking [ON]
              # lcm    glo_l   LAMP   (0000 0011) LOW [ON] Parking [ON]
              # lcm    glo_l   LAMP   (0000 0011) LOW [ON] Parking [ON]
              # lcm    glo_l   LAMP   (0000 0011) LOW [ON] Parking [ON]
              # lcm    glo_l   LAMP   (0000 0011) LOW [ON] Parking [ON]
              # lcm    glo_l   LAMP   (0000 0000)
              # lcm    glo_l   LAMP2? b0: 0xff ((1111 1111) Rapid. [ON])
              # weird how... after lamp is off... LAMP2 _always_ goes back to 0xFF?
              0b0000_1000 => :test_x,
              0b0000_0100 => :unknown,
              # like above.. just turned in interior backlight as if night
              0b0000_0010 => :night,
              0b0000_0001 => :unknown
            }

            def lcm(*args)
              vehicle_control(to: :lcm, arguments: array(args))
            end
          end
        end
      end
    end
  end
end
