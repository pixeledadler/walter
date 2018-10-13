require 'helpers/manageable_threads'
require 'helpers/delayable'

module ModuleTools
  # Retrieve a constant from a String i.e. "NameSpaceA::ClassX"
  def get_class(name)
    Kernel.const_get(name)
  end

  def prepend_namespace(command_namespace, klass)
    "#{command_namespace}::#{klass}"
  end
end

module DeviceTools
  MEDIA = [:cdc, :cd, :rad, :dsp, :gfx, :tv, :bmbt]
end

module CommandTools
  KEEP_ALIVE = [0x01, 0x02]
  SPEED = [0x18]
  TEMPERATURE = [0x1D, 0x19]
  IGNITION = [0x10, 0x11]
  IKE_SENSOR = [0x12, 0x13]
  COUNTRY = [0x14, 0x15]

  MID_TXT = [0x21]

  OBC = [0x2A, 0x40, 0x41]

  BUTTON = [0x48, 0x49]

  VEHICLE = [0x53, 0x54]
  LAMP = [0x5A, 0x5B]
  DOOR = [0x79, 0x7A]

  CD_CHANGER = [0x38, 0x39]

  NAV = [0x4f]

  DIA = [0x00, 0x04, 0x05, 0x08, 0x0B, 0x0C, 0x30, 0x3F, 0x60, 0x6B, 0x69, 0x65, 0x9C, 0x9F, 0xA2, 0xA0, 0x06, 0x07, 0x09, 0x1b]
end

module WalterTools
  PROC_MOD = 'WalterTools'.freeze

  def defaults
    LOGGER.info(PROC_MOD) { 'Applying debug defaults.' }
    ping
    ign
  end

  # Session

  def messages
    SessionHandler.i.messages
  end

  # DisplayHandler

  def s
    DisplayHandler.instance.enable
  end

  def h
    DisplayHandler.instance.disable
  end

  def diag
    DisplayHandler.i.filter_commands(*CommandTools::DIA)
  end

  def obc
    DisplayHandler.i.filter_commands(*CommandTools::OBC)
  end

  def ping
    DisplayHandler.i.filter_commands(*CommandTools::KEEP_ALIVE)
  end

  def shutup!
    DisplayHandler.i.shutup!
  end

  def ign
    DisplayHandler.i.filter_commands(*CommandTools::IGNITION)
  end

  def c
    DisplayHandler.i.clear_filter
  end

  def media
    DisplayHandler.i.f_t(* DeviceTools::MEDIA + [:glo_h, :glo_l] )
    DisplayHandler.i.f_f(*DeviceTools::MEDIA)
  end

  def cd
    DisplayHandler.i.filter_commands(*CommandTools::CD_CHANGER)
  end

  # Logging

  def debug
    LOGGER.sev_threshold=(Logger::DEBUG)
  end

  def info
    LOGGER.sev_threshold=(Logger::INFO)
  end

  # Annoying Tasks :)

  def hello?
    t0 = messages.count
    Kernel.sleep(1)
    t1 = messages.count
    r = t1 - t0
    LOGGER.info(PROC_MOD) { "#{r} new messages in the last second." }
    r.positive? ? true : false
  end

  def news
    print_status(true)
    true
  end

  def nl
    new_line_thread = Thread.new do
      Thread.current[:name] = 'New Line'
      Kernel.sleep(0.5)
      LOGGER.unknown('Walter') { 'New Line' }
    end
    add_thread(new_line_thread)
  end

  # Delay

  def rate(seconds)
    @interface.sleep_time = seconds
  end

  def sleep
    @interface.sleep_enabled = true
    sleep_time = @interface.sleep_time
    LOGGER.info(PROC) { "Sleep ENABLED with rate of #{sleep_time} seconds" }
    sleep_time
  end

  def no_sleep
    @interface.sleep_enabled = false
    sleep_time = @interface.sleep_time
    LOGGER.info(PROC) { "Sleep DISABLED with rate of #{sleep_time} seconds" }
    true
  end

  # API

  def fuck_yeah!
    @bus_device.update(chars: "fuck yeah".bytes, ike: :set_ike, gfx: :radio_set)
  end

  def key
    @bus_device.state(key: :key_6, status: 0x04)
  end
end

module ClusterTools
  HUD_SIZE = 20

  def centered(chars_string, opts = { upcase: true })
    upcase = opts[:upcase]

    chars_string = chars_string.center(HUD_SIZE)
    chars_string = chars_string.upcase if upcase
    chars_string
  end
end

module NameTools
  # Convert a symbol :name to instance variable name
  # @return [Instance Variable Name] :@variable_name
  def inst_var(name)
    name_string = name.id2name
    '@'.concat(name_string).to_sym
  end

  # Convert a symbol :name to class variable name
  # @return [Class Variable Name] :@@variable_name
  def class_var(name)
    name_string = name.id2name
    '@@'.concat(name_string).to_sym
  end

  # # Convert a symbol :name to class constant name
  # @return [Class Constant Name] :CONSTANT_NAME
  def class_const(name)
    name_string = name.upcase
    name_string.to_sym
  end
end

module Helpers
  include ModuleTools
  extend ModuleTools
  include NameTools
  include DeviceTools
end
