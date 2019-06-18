# frozen_string_literal: true

module Wilhelm::SDK
  class Node
    # Comment
    module State
      include Constants

      def change_state(new_state)
        logger.debug(NODE) { "State => #{new_state.class}" }
        @state = new_state
        changed
      notify_observers(state)
        @state
      end
    end
  end
end
