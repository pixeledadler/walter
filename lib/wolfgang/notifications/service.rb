# frozen_string_literal: true

# Comment
module Wolfgang
  class Notifications
    include LogActually::ErrorOutput
    attr_accessor :listener, :handler, :context
    attr_writer :bus
    alias wolfgang_context context

    include Logger

    def initialize(wolfgang_context)
      @context = wolfgang_context
      @state = Inactive.new
    end

    def bus
      context.bus
    end

    def start
      logger.debug(self.class) { '#start' }
      @state.start(self)
    end

    def stop
      logger.debug(self.class) { '#stop' }
      @state.stop(self)
    end

    def change_state(new_state)
      logger.info(self.class) { "state change => #{new_state.class}" }
      @state = new_state
    end
  end
end
