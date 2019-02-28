# require 'physical/interface/UART'
# require 'physical/interface/file'
# require 'physical/interface/byte_buffer'
# require 'physical/interface/output_buffer'

require 'helpers'

class Interface
  include Observable
  include ManageableThreads
  include Delayable

  FILE_TYPE = { tty: 'characterSpecial', file: 'file' }.freeze
  FILE_TYPE_HANDLERS = { tty: Interface::UART, file: Interface::File }.freeze
  DEFAULT_PATH = '/dev/cu.SLAB_USBtoUART'.freeze
  NO_OPTIONS = {}.freeze

  PROC = 'Interface'.freeze

  attr_reader :input_buffer, :output_buffer, :read_thread

  def log
    :interface
  end

  def name
    Thread.current[:name]
  end

  # The interface should protect the interface from the implementation.
  # i shouldn't be forwarding methods.. that's what bit me with rubyserial
  # i was tried to the API of the library.. and not protected for it
  # it's responsible for a consistent APi. how #read is implemented

  def initialize(path, options = NO_OPTIONS)
    @stream = parse_path(path, options)

    @input_buffer = ByteBuffer.new
    @output_buffer = OutputBuffer.new(@stream)
  end

  def on
    offline?

    @read_thread = thread_populate_input_buffer(@stream, @input_buffer)
    add_thread(@read_thread)
  end

  def off
    LogActually.interface.debug(PROC) { "#off" }
    close_threads
  end

  # This should be implemented in a sub class of Interface
  def offline?
    if @stream.instance_of?(Interface::File)
      changed
      notify_observers(Event::BUS_OFFLINE, @stream.class)
      return true
    elsif @stream.instance_of?(Interface::UART)
      changed
      notify_observers(Event::BUS_ONLINE, @stream.class)
      return false
    else
      raise StandardError, 'no status!'
    end
  end

  private

  def parse_path(path, options)
    LogActually.interface.debug(PROC) { "#parse_path(#{path}, #{options})" }
    path = DEFAULT_PATH if path.nil?
    path = ::File.expand_path(path)
    file_type_handler = evaluate_stream_type(path)
    LogActually.interface.debug(PROC) { "File handler: #{file_type_handler}" }
    file_type_handler.new(path, options)
  end

  def evaluate_stream_type(path)
    LogActually.interface.debug(PROC) { "Evaluating file type of: #{path}" }
    file_type = ::File.ftype(path)
    LogActually.interface.debug(PROC) { "#{path} of type: #{file_type}" }
    case file_type
    when FILE_TYPE[:tty]
      LogActually.interface.debug(PROC) { "#{file_type} handled by: #{FILE_TYPE_HANDLERS[:tty]}" }
      FILE_TYPE_HANDLERS[:tty]
    when FILE_TYPE[:file]
      LogActually.interface.debug(PROC) { "#{file_type} handled by: #{FILE_TYPE_HANDLERS[:file]}" }
      FILE_TYPE_HANDLERS[:file]
    else
      raise IOError, "Unrecognised file type: #{File.ftype(path)}"
    end
  end

  # ------------------------------ THREADS ------------------------------ #

  def thread_populate_input_buffer(stream, input_buffer)
    LogActually.interface.debug(PROC) { "#thread_populate_input_buffer" }
    Thread.new do
      thread_name = 'Interface (Input Buffer)'
      tn = thread_name

      Thread.current[:name] = tn

      begin
        delay_defaults
        read_byte = nil
        parsed_byte = nil
        offline_file_count = 1

        # LogActually.interface.debug "Stream / Position: #{stream.pos}"

        loop do
          begin
            read_byte = nil
            parsed_byte = nil
            # readpartial will block until 1 byte is avaialble. This will
            # cause the thread to sleep

            read_byte = stream.readpartial(1)
            delay if @stream.instance_of?(Interface::File)

            # when using ARGF to concatonate multiple log files
            # readpartial will return an empty string to denote the end
            # of one file, only rasing EOF on last file
            raise EncodingError if read_byte.nil?

            parsed_byte = Byte.new(:encoded, read_byte)
            byte_basic = ByteBasic.new(read_byte)

            # NOTE this is intesresting.. this event isn't to do with the
            # primary processing..it's only for logging..
            # i could technically have a state of ByteBuffer being:
            #   1. PendingData
            #   2. NoData
            changed
            notify_observers(Event::BYTE_RECEIVED, read_byte: read_byte, parsed_byte: parsed_byte, byte_basic: byte_basic, pos: stream.pos)

            input_buffer.push(byte_basic)
          rescue EncodingError => e
            if stream.class == FILE_TYPE_HANDLERS[:file]
              LogActually.interface.warn(tn) { "ARGF EOF. Files read: #{offline_file_count}." }
              offline_file_count += 1
            elsif stream.class == FILE_TYPE_HANDLERS[:tty]
              LogActually.interface.error(tn) { "#readpartial returned nil. Stream type: #{}." }
            end
            # LogActually.interface.error(")
            # sleep 2
            # e.backtrace.each { |l| LogActually.interface.error l }
            # LogActually.interface.error("read_byte: #{read_byte}")
            # LogActually.interface.error("parsed_byte: #{parsed_byte}")
            # binding.pry
          end
        end
      rescue EOFError
        LogActually.interface.warn(PROC) { "#{tn}: Stream reached EOF!" }
      rescue StandardError => e
        LogActually.interface.error(PROC) { "#{tn}: #{e}" }
        e.backtrace.each { |line| LogActually.interface.error(PROC) { line } }
      end
      LogActually.interface.warn(PROC) { "#{tn} thread is ending." }
    end
  end
end