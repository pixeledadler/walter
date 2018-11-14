class Virtual
  class Device
    include Observable
    include Receivable

    PROC = 'Device'.freeze

    attr_reader :ident

    alias_method :me, :ident

    def initialize(device_ident)
      @ident = device_ident
    end

    def i_am(other)
      ident == other
    end

    def type
      :dumb
    end

    # @override Object#inspect
    def inspect
      "#<Device :#{@ident}>"
    end

    # @override Object#to_s
    def to_s
      "<:#{@ident}>"
    end
  end

  class BroadcastDevice < Device
    PROC = 'BroadcastDevice'.freeze

    def type
      :broadcast
    end
  end

  class SimulatedDeviceBuilder
    include ModuleTools

    CLASS_MAP = {
      dsp: 'SimulatedDSP',
      cdc: 'SimulatedCDC',
      tel: 'SimulatedTEL'
    }.freeze

    attr_reader :ident

    def simulate(ident)
      raise StandardError, "no class to simulate #{ident}" unless CLASS_MAP.key?(ident)
      @ident = ident
      self
    end

    def result
      raise StandardError, "no ident set!" unless @ident
      klass_constant = CLASS_MAP[ident]
      klass_constant = prepend_namespace('Virtual', klass_constant)
      klass = get_class(klass_constant)
      klass.new(ident)
    end
  end

  require 'application/virtual/stateful'
  require 'application/virtual/alive'
  require 'application/virtual/cd'
  require 'application/virtual/telephone'

  class SimulatedDevice < Device
    include CommandAliases

    DEFAULT_STATUS = :down

    include Alive

    PROC = 'SimulatedDevice'.freeze

    def self.builder
      SimulatedDeviceBuilder.new
    end

    def initialize(args)
      super(args)
      @status = DEFAULT_STATUS
    end

    def type
      :simulated
    end

    def enable
      @status = :up
    end

    def disable
      @status = :down
    end

    def enabled?
      case @status
      when nil
        false
      when :up
        true
      when :down
        false
      end
    end

    def disabled?
      case @status
      when nil
        false
      when :up
        false
      when :down
        true
      end
    end

    # @override Object#inspect
    def inspect
      "#<SimulatedDevice :#{@ident}>"
    end

    # @override Object#to_s
    def to_s
      "<:#{@ident}>"
    end

    # @override Virtual::Device#receive_packet
    def receive_packet(packet)
      message = super(packet)
      handle_message(message) if enabled?
    end

    def handle_message(message)
      command_id = message.command.d
      case command_id
      when PING
        respond
      end
    end

    def alt
      @alt ||= AddressLookupTable.instance
    end

    def address(ident)
      alt.get_address(ident)
    end

    def my_address
      alt.get_address(ident)
    end
  end

  class SimulatedDSP < SimulatedDevice
    PROC = 'SimulatedDSP'.freeze

    def handle_message(message)
      command_id = message.command.d
      case command_id
      when DSP_EQ
        true
      end

      super(message)
    end
  end

  class SimulatedCDC < SimulatedDevice
    include CD

    PROC = 'SimulatedDSP'.freeze

    def handle_message(message)
      command_id = message.command.d
      case command_id
      when CHANGER_REQUEST
        handle_changer_request(message)
      end

      super(message)
    end
  end

  class SimulatedTEL < SimulatedDevice
    include Telephone

    PROC = 'SimulatedTEL'.freeze

    def handle_message(message)
      command_id = message.command.d
      LOGGER.debug('SimulatedTEL!') { "handle message id: #{command_id}" }
      case command_id
      when PONG
        LOGGER.debug('SimulatedTEL!') { "handling pong" }
        handle_announce(message)
      when GFX_STATUS
        handle_gfx_status(message)
      when TEL_DATA
        handle_data_request(message)
      when TEL_OPEN
        handle_tel_open(message)
      end

      super(message)
    end
  end

  class DynamicDevice < Device
    include CommandAliases

    DEFAULT_STATUS = :down

    def self.builder
      SimulatedDeviceBuilder.new
    end

    def initialize(args)
      super(args)
      @status = DEFAULT_STATUS
    end

    def enable
      @status = :up
    end

    def disable
      @status = :down
    end

    def enabled?
      case @status
      when nil
        false
      when :up
        true
      when :down
        false
      end
    end

    def disabled?
      case @status
      when nil
        false
      when :up
        false
      when :down
        true
      end
    end

    def alt
      @alt ||= AddressLookupTable.instance
    end

    def address(ident)
      alt.get_address(ident)
    end

    def my_address
      alt.get_address(ident)
    end

    # @override Virtual::Device#receive_packet
    # Allows the introduction of custom behaviour
    def receive_packet(packet)
      message = super(packet)
      handle_message(message) if enabled?
    end
  end

  class AugmentedDevice < DynamicDevice
    PROC = 'AugmentedDevice'.freeze

    def initialize(args)
      super(args)
    end

    def type
      :augmented
    end

    # @override Object#inspect
    def inspect
      "#<AugmentedDevice :#{@ident}>"
    end

    # @override Object#to_s
    def to_s
      "<:#{@ident}>"
    end
  end
end
