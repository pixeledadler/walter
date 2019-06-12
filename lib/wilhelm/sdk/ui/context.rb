module Wilhelm
  class UserInterface
    class Context
      attr_accessor :application_context, :header, :service
      attr_reader :renderer
      alias context application_context

      # TODO: configuration file...
      ROOT_CONTROLLER = :debug

      def initialize(application_context, options = {
        renderer: Wilhelm::API::Display.instance
      })
        @application_context = application_context
        @renderer = options[:renderer]
        # register_service_controller(:debug, )
      end

      def register_service_controllers(service_controller_hash)
        service_controller_hash.each do |name, klass|
          register_service_controller(name, klass)
        end
      end

      def register_service_controller(name, klass)
        LogActually.ui.debug('UIContext') { "#register_service_controller(#{name}, #{klass})" }
        service_controllers[name] = klass
      end

      def service_controllers
        @service_controllers ||= {}
      end

      def to_s
        '<UserInterface>'
      end

      def inspect
        '<UserInterface>'
      end

      def render_menu(view)
        renderer.render_menu(view)
      end

      def render_header(view)
        renderer.render_new_header(view)
      end

      alias render render_menu

      def launch(feature, action, args = nil)
        LogActually.ui.debug('UIContext') { "#launch(#{feature}, #{action}, #{args})" }
        if feature == :header || !header
          header&.destroy
          header_controller = service_controllers[:header]
          @header = header_controller.new(self, application_context)
          return @header.load(:header, args) if args
          @header.load(:header)
        end

        service&.destroy
        service_klass = service_controllers[feature]
        @service = service_klass.new(self, application_context) unless service.class === service_klass
        return service.load(action, args) if args
        service.load(action)
      rescue StandardError => e
        LogActually.ui.error(self.class.name) { e }
        e.backtrace.each { |line| LogActually.ui.error(self.class.name) { line } }
        LogActually.ui.error(self.class.name) { 'binding.pry start' }
        binding.pry
        LogActually.ui.error(self.class.name) { 'binding.pry end' }
      end
    end
  end
end
