# frozen_string_literal: true

module Wilhelm
  module Virtual
    class Device
      module Radio
        module Capabilities
          module Analogue
            # Analogue Radio Display
            module Display
              include API

              # rad  gt  23  CA 20  "CD 1-01",
              # rad  gt  23  CA 20  "CD 1-01",
              # rad  gt  23  CA 20  "CD 1-01",
              # rad  gt  23  CA 20  "CD 1-01",

              # "FM \x03105.9\x04   "
              # "FM \x03105.9\x04 ST"

              STATION    = [70, 77, 32, 3, 49, 48, 53, 46, 57, 4, 32, 32, 32].freeze
              STATION_ST = [70, 77, 32, 3, 49, 48, 53, 46, 57, 4, 32, 83, 84].freeze

              def station(to: :gt, chars: integer_array_to_chars(STATION))
                draw_23(to: to, gt: 0x40, ike: 0x20, chars: chars)
              end

              def st(to: :gt, chars: integer_array_to_chars(STATION_ST))
                draw_23(to: to, gt: 0x50, ike: 0x20, chars: chars)
              end

              PRESETS = {
                1 => " 1\x052*", # [32, 49, 5, 50, 42] (" 1☐2*")
                2 => "2*\x05 3", # [50, 42, 5, 32, 51] ("2*☐ 3")
                3 => "2 \x05*3", # [50, 32, 5, 42, 51] ("2 ☐*3")
                4 => " 3\x054*", # [32, 51, 5, 52, 42] (" 3☐4*")
                5 => "4 \x05*5", # [52, 32, 5, 42, 53] ("4 ☐*5")
                6 => " 5\x056*"  # [32, 53, 5, 54, 42] (" 5☐6*")
              }.freeze
              # [42, 49, 6, 5, 52, 32] ("*1☐☐4 ")
              # [50, 32, 5, 5, 52, 42] ("2 ☐☐4*")

              # C23
              def preset(index = 1)
                list(layout: 0x41, m2: index, m3: 0x01, chars: PRESETS[index])
              end

              # BM53
              def preset!(index = 1, block = true)
                b = block ? 0x00 : 0x01
                secondary(gt: 0x62, ike: b, zone: 0x42, chars: " P #{index} ")
                # Kernel.sleep(2)
                # secondary(gt: 0x62, ike: 0x00, zone: 0x42, chars: " P #{index+1} ")
              end

              def channel!(index = 1, block = true)
                b = block ? 0x00 : 0x01
                secondary(gt: 0x62, ike: b, zone: 0x01, chars: " FM#{index} ")
              end
            end
          end
        end
      end
    end
  end
end
