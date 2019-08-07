# frozen_string_literal: false

module Wilhelm
  module Virtual
    class Command
      # Virtual::Command::Speed
      class Speed < Base
        SPEED_UNIT = 'kmph'.freeze
        REV_UNIT = 'rpm'.freeze

        # @override
        def to_s
          fast = parse_reading(*speed.value, 2, SPEED_UNIT)
          rev = parse_reading(*rpm.value, 100, REV_UNIT)

          str_buffer = sprintf("%-10s", sn)
          str_buffer = str_buffer.concat("\tSpeed: #{fast}, RPM: #{rev}")
          str_buffer
        end

        def inspect
          fast = parse_reading(*speed.value, 2, SPEED_UNIT)
          rev = parse_reading(*rpm.value, 100, REV_UNIT)

          str_buffer = sprintf("%-10s", sn)
          str_buffer = str_buffer.concat("\tSpeed: #{fast}, RPM: #{rev}")
          str_buffer
        end

        private

        def parse_reading(reading, multiplier, unit)
          calculated_value = reading * multiplier
          "#{calculated_value}#{unit}"
        end
      end
    end
  end
end
