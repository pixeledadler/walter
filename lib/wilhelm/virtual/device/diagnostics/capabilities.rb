# frozen_string_literal: true

require_relative 'capabilities/constants'
require_relative 'capabilities/body'
require_relative 'capabilities/lighting'
require_relative 'capabilities/display'

module Wilhelm
  module Virtual
    class Device
      module Diagnostics
        # Device::Diagnostics::Capabilities
        module Capabilities
          include Body
          include Display
          include Lighting
        end
      end
    end
  end
end
