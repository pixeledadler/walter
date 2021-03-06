# frozen_string_literal: false

require_relative 'capabilities/constants'

require_relative 'capabilities/auxiliary'
require_relative 'capabilities/code'
require_relative 'capabilities/controls'
require_relative 'capabilities/obc'
require_relative 'capabilities/monitor'
require_relative 'capabilities/remote_control'
require_relative 'capabilities/settings'
require_relative 'capabilities/ui'

module Wilhelm
  module Virtual
    class Device
      module GT
        # Device::GT
        module Capabilities
          include AuxiliaryVentilation
          include Code
          include Controls
          include OnBoardComputer
          include Monitor
          include RemoteControl
          include Settings
          include UserInterface
        end
      end
    end
  end
end
