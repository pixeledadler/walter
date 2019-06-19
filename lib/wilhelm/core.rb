# frozen_string_literal: true

puts 'Loading wilhelm/core'

module Wilhelm
  # Setup namespace due to short class names in wilhelm-core
  module Core
  end
end

# Walter-Core
LogActually.is_all_around(:interface)
LogActually.interface.i
LogActually.is_all_around(:datalink)
LogActually.datalink.i
LogActually.is_all_around(:multiplexer)
LogActually.multiplexer.i
LogActually.is_all_around(:demultiplexer)
LogActually.demultiplexer.i
LogActually.is_all_around(:transmitter)
LogActually.transmitter.i
LogActually.is_all_around(:parameterized)
LogActually.parameterized.i

puts "\tLoading wilhelm/core/serialport"
require 'serialport'

require_relative 'core/constants'
require_relative 'core/helpers'
require_relative 'core/shared'
require_relative 'core/physical'
require_relative 'core/datalink'
require_relative 'core/listener'
require_relative 'core/handler'
require_relative 'core/ibus'
require_relative 'core/context'

puts "\tDone!"
