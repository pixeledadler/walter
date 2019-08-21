# frozen_string_literal: true

require_relative 'status/state'
require_relative 'status/modifiers'

module Wilhelm
  module Virtual
    class Device
      module Telephone
        class Emulated < Device::Emulated
          module State
            # Telephone::Emulated::Status
            module Status
              include State
              include Modifiers

              def on!
                on.status!
              end

              def active!
                active.status!
              end

              def inactive!
                inactive.status!
              end

              def handset!
                handset.status!
              end

              # API
              def status_bit_field
                i = 0
                i |= 1 << STATUS_SHIFT_BIT_1    if bit1?
                i |= 1 << STATUS_SHIFT_BIT_2    if bit2?
                i |= 1 << STATUS_SHIFT_ACTIVE   if active?
                i |= 1 << STATUS_SHIFT_POWER    if power?
                i |= 1 << STATUS_SHIFT_DISPLAY  if display?
                i |= 1 << STATUS_SHIFT_INCOMING if incoming?
                i |= 1 << STATUS_SHIFT_MENU     if menu?
                i |= 1 << STATUS_SHIFT_HFS      if hfs?
                i
              end
            end
          end
        end
      end
    end
  end
end
