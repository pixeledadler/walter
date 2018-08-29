require 'printable'

class Message
  include Printable
  attr_accessor :sender, :receiver, :command, :arguments

  attr_accessor :frame

  alias :to           :receiver
  alias :from         :sender

  alias :destination  :receiver
  alias :source       :sender

  def initialize(from, to, command, arguments = nil)
    @sender     = from
    @receiver   = to
    @command    = command
    @arguments  = arguments unless arguments.nil?

    # Printable
    parse_mapped_bytes(bytes)
  end

  def to_f
    @frame.string
  end

  # ------------------------------ INFO ------------------------------ #

  def to_s
    # LOGGER.warn("#{command.verbose}")
    return inspect if command.verbose
    str_buffer = "#{from.sn}\t#{to.sn}\t#{@command}"
    # args_str_buffer = @arguments.join(' ') { |a| a.to_h(true) }
    # str_buffer.concat(" #{args_str_buffer}") unless args_str_buffer.empty?
    str_buffer
  end

  def inspect
    # LOGGER.warn('inspect')
    # sprintf("%-10s", "[Message]").concat(str_buffer)
    "#{from.sn}\t#{to.sn}\t#{command.inspect}"
  end

  # ------------------------------ PRINTABLE ------------------------------ #

  def reparse!
    parse_mapped_bytes(bytes)
  end

  # TODO the objects should keep/instatiate their own lazy Bytes
  def bytes
    b_from = Byte.new(:decimal, from.d)
    b_to = Byte.new(:decimal, to.d)
    b_command = Byte.new(:decimal, command.d)

    # command arguments is just an array of Bytes...
    # b_arguments = command.arguments
    command_arguments = command.bytes

    { Tx: b_from, Rx: b_to, CMD: b_command }.merge(command_arguments)
  end
end
