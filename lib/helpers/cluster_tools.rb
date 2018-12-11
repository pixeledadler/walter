module ClusterTools
  HUD_SIZE = 20

  LEFT = :ljust
  CENTERED = :center
  RIGHT = :rjust

  ALIGNMENTS = [LEFT, CENTERED, RIGHT].freeze

  def align(chars_string, alignment = CENTERED)
    raise ArgumentError, "Invalid alignment #{alignment}" unless ALIGNMENTS.include?(alignment)
    chars_string.public_send(alignment, HUD_SIZE)
  end

  def centered(chars_string, opts = { upcase: true })
    upcase = opts[:upcase]

    chars_string = chars_string.center(HUD_SIZE)
    chars_string = chars_string.upcase if upcase
    chars_string
  end

  def encoding
    (0..255).step(10) do |x|
      line = 20.times.map do |i|
        "#{(x+i).chr rescue 0}"
      end.join(' ')
      @bus_device.displays({ gfx: 0x40, ike: 0x30, chars: line }, 0xC8, 0x80 )
      Kernel.sleep(5)
    end
  end
end
