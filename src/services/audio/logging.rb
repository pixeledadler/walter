# frozen_string_literal: true

module Wolfgang
  class Audio
    # Comment
    module Logging
      include Constants

      def to_s
        "Audio (#{state_string})"
      end

      def nickname
        :audio
      end

      def state_string
        case state
        when On
          'On'
        when Enabled
          'Enabled'
        when Disabled
          'Disabled'
        else
          state.class
        end
      end

      def logger
        LogActually.audio_service
      end
    end
  end
end