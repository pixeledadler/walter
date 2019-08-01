# frozen_string_literal: false

module Wilhelm
  module Virtual
    class Device
      module GFX
        module Capabilities
          # BMBT Interface Control
          module UserControls
            include API

            def select(i, l = 0x60)
              input(layout: l, index: i)
            end

            def fm!(l = 0x60)
              input(layout: l, index: 6)
            end

            def am!(l = 0x60)
              input(layout: l, index: 7)
            end

            def sc!(l = 0x60)
              input(layout: l, index: 8)
            end

            def cd!(l = 0x60)
              input(layout: l, index: 9)
            end

            def tape!(l = 0x60)
              input(layout: l, index: 10)
            end

            def empty!(l = 0x60)
              input(layout: l, index: 11)
            end

            # " 1 ☐ 2 ☐ 3 ☐ 4 ☐ 5 ☐ 6 "
            # "FM☐AM☐SC☐CD☐TAPE☐   "

            def input(layout: 0x60, index: 11)
              user_input(layout: layout, function: 0x00, button: index)
              Kernel.sleep(0.05)
              user_input(layout: layout, function: 0x00, button: (index + 0x40))
            end
          end
        end
      end
    end
  end
end
