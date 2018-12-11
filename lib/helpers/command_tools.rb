module CommandTools
  KEEP_ALIVE = [0x01, 0x02].freeze
  SPEED = [0x18].freeze
  TEMPERATURE = [0x1D, 0x19].freeze
  IGNITION = [0x10, 0x11].freeze
  IKE_SENSOR = [0x12, 0x13].freeze
  COUNTRY = [0x14, 0x15].freeze

  MID_TXT = [0x21].freeze

  OBC = [0x2A, 0x40, 0x41].freeze

  BUTTON = [0x32, 0x3B, 0x48, 0x49].freeze
  BUTTONS = BUTTON

  VEHICLE = [0x53, 0x54].freeze
  LAMP = [0x5A, 0x5B].freeze
  DOOR = [0x79, 0x7A].freeze

  CD_CHANGER = [0x38, 0x39].freeze

  NAV = [0x4f].freeze

  DIA = [0x00, 0x04, 0x05, 0x08, 0x0B, 0x0C, 0x30, 0x3F, 0x60, 0x6B, 0x69, 0x65, 0x9C, 0x9F, 0xA2, 0xA0, 0x06, 0x07, 0x09, 0x1b].freeze
end
