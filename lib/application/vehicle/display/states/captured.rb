class Vehicle
  class Display
    # In use by Walter
    class Captured
      include Defaults

      DISPLAY_CAPTURED = 'Display (Cap.)'

      def user_input(context, method, properties)
        context.logger.debug(DISPLAY_CAPTURED) { "#user_input(#{method})" }
        context.menu.public_send(method, properties)
      end

      def render_header(context, view)
        # context.header = view
        # context.bus.rad.build_header(view.layout, view.fields_with_index, view.title)
        # context.change_state(Captured.new)
      end

      def input_menu(context)
        LogActually.display.info(DISPLAY_CAPTURED) { "#input_menu" }
        context.change_state(Enabled.new)
      end

      # def input_select(context)
      #   LogActually.display.info(DISPLAY_CAPTURED) { "#input_select" }
      #   context.change_state(Enabled.new)
      # end

      def render_new_header(context, view)
        case view.type
        when :default
          context.default_header = view
          context.header = view
        when :notification
          context.notification_header = view
          context.header = view
          Thread.new(context, view) do |contextual, vuew|
            begin
              Kernel.sleep(contextual.timeout)
              result = contextual.dismiss(vuew)
              LogActually.display.debug(DISPLAY_CAPTURED) { "Dimiss? => #{result}" }
            rescue StandardError => e
              LogActually.display.error(DISPLAY_CAPTURED) { e }
            end
            LogActually.display.warn(DISPLAY_CAPTURED) { 'Notify dismiss thread ending?' } unless result
          end
        end
        context.bus.rad.build_new_header(view.layout, view.fields_with_index, view.title)
        # context.change_state(Captured.new)
      end

      def dismiss(context, view)
        return false unless context.notification_header == view
        context.render_new_header(context.default_header)
        context.header = context.default_header
        context.notification_header = nil
        true
      end

      def render_menu(context, view)
        context.menu = view
        context.bus.rad.build_menu(view.layout, view.menu_items_with_index)
        # context.change_state(Captured.new)
        true
      end

      def overwritten!(context)
        context.logger.warn(DISPLAY_CAPTURED) { "#overwritten!()" }
        context.bus.rad.render(context.header.layout)
        context.bus.rad.render(context.menu.layout)
      end
    end
  end
end