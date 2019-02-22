module Wolfgang
  class UserInterface
    attr_accessor :context, :header, :root
    # attr_reader :root

    def to_s
      '<UserInterface>'
    end

    def inspect
      '<UserInterface>'
    end

    def initialize(context, root = Controller::MainMenuController, header = Controller::HeaderController)
      @context = context
      @header = create_header(header)
      @root = create_menu(root)
    end

    def audio_controller
      @audio_controller ||= Controller::AudioController.new(context)
    end

    def bluetooth_controller
      @bluetooth_controller ||= Controller::BluetoothController.new(context)
    end

    def header_controller
      @header_controller ||= Controller::HeaderController.new(context)
    end

    def create_header(header_controller)
      x = header_controller.new(context)
      x.load_header
      x
    end

    def create_menu(root_controller)
      y = root_controller.new(context)
      y.load
      y
    end
  end
end