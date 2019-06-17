# frozen_string_literal: false

module Wilhelm
  module Core
    # DebugTools
    # Helpers for common tasks on CLI
    module Debug
      module Session
        def messages
          SessionHandler.i.messages
        end

        def hello?
          t0 = messages.count
          Kernel.sleep(1)
          t1 = messages.count
          r = t1 - t0
          LOGGER.info(PROC_MOD) { "#{r} new messages in the last second." }
          r.positive? ? true : false
        end
      end
    end
  end
end
