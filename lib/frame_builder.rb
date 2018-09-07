# frozen_string_literal: true

require 'new_frame'

# Class documentation
class FrameBuilder
  REQUIRED_FIELDS = %i[from to command arguments].freeze
  CALCULATED_FIELDS = %i[length fcs].freeze
  ALL_FIELDS = REQUIRED_FIELDS + CALCULATED_FIELDS

  DEFAULT_VALUE = nil
  INST_VAR_PREFIX = '@'

  DEFAULT_LENGTH = 1
  ARGS_INDEX = 2
  ARGS_TAIL_INDEX = ARGS_INDEX
  ARGS_FRAME_INDEX = -1

  attr_accessor :from, :to, :command, :arguments
  attr_reader :length, :fcs

  def initialze
    ALL_FIELDS.each do |field|
      instance_variable_set(inst_var(field), DEFAULT_VALUE)
    end
  end

  def clone(frame)
    @from = frame.from
    LOGGER.warn('FrameBuilder') { "from: #{from}" }
    @to = frame.to
    LOGGER.warn('FrameBuilder') { "to: #{to}" }
    @command = frame.command
    LOGGER.warn('FrameBuilder') { "command: #{command}" }
    @arguments = frame.arguments
    LOGGER.warn('FrameBuilder') { "arguments: #{arguments}" }
    true
  end

  def result
    raise ArgumentError, 'req fields not set!' unless all_required_fields_set?

    generate_calculated_fields
    new_frame = generate_new_frame
    new_frame.valid?
    new_frame
  end

  def generate_calculated_fields
    generate_length
    generate_fcs
  end

  def generate_new_frame
    new_frame = NewFrame.new
    new_frame.set_header(generate_header)
    new_frame.set_tail(generate_tail)
    new_frame
  end

  def generate_header
    Bytes.new([from, length])
  end

  def generate_tail
    bytes = Bytes.new([to, command, fcs])
    bytes.insert(ARGS_INDEX, *arguments) unless no_arguments?
    bytes
  end

  def no_arguments?
    raise ArgumentError, 'command args hasn\'t been set yet!' if arguments.nil?
    arguments.empty?
  end

  def all_required_fields_set?
    result = REQUIRED_FIELDS.none?(&:nil?)
    return true if result
    fields_not_set = REQUIRED_FIELDS.find_all(&:nil?)
    LOGGER.warn('FrameBuilder') { "Required fields: #{fields_not_set}" }
    false
  end

  def calculate_length
    to_len =       DEFAULT_LENGTH
    command_len =  DEFAULT_LENGTH
    args_len =     @arguments.length
    fcs_len =      DEFAULT_LENGTH

    to_len + command_len + args_len + fcs_len
  end

  def calculate_fcs
    checksum = all_fields.reduce(0) { |c, d| c ^= d.to_d }
    LOGGER.debug('FrameBuilder') { "Checksum / Calculated = #{checksum}" }
    checksum
  end

  def generate_fcs
    @fcs = Byte.new(:decimal, calculate_fcs)
  end

  def generate_length
    @length = Byte.new(:decimal, calculate_length)
  end

  def all_fields
    bytes = Bytes.new([from, length, to, command])
    bytes.insert(ARGS_TAIL_INDEX, *arguments) unless no_arguments?
    bytes
  end

  def inst_var(name)
    name_string = name.id2name
    INST_VAR_PREFIX.concat(name_string).to_sym
  end
end
