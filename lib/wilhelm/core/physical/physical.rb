# frozen_string_literal: true

puts "\tLoading wilhelm/core/physical"

require 'physical/byte'
require 'physical/byte_basic'
require 'physical/bytes'

puts "\tLoading wilhelm/core/physical/interface"

require 'physical/interface/UART'
require 'physical/interface/file'
require 'physical/interface'
require 'physical/interface/byte_buffer'
require 'physical/interface/output_buffer'
