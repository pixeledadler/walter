# frozen_string_literal: true

module Wolfgang
  class UserInterface
    module View
      # Comment
      class DefaultHeader < BaseHeader
        TYPE = :default
      end
    end
  end
end

module Wolfgang
  class UserInterface
    module View
      module Audio
        # Comment
        class NowPlaying < DefaultHeader
          def initialize(addressed_player)
            super(
              [nil,
               nil,
               status?(addressed_player.status),
               addressed_player.album,
               addressed_player.name,
               addressed_player.artist],
               addressed_player.title)
          end

          # "playing", "stopped", "paused", "forward-seek",
          # "reverse-seek" or "error"
          def status?(input)
            case input
            when 'playing'
              '>'
            when 'stopped'
              '#'
            when 'paused'
              '='
            when 'forward-seek'
              187.chr
            when 'reverse-seek'
              171.chr
            when 'error'
              191.chr
            else
              '?'
            end
          end
        end
      end
    end
  end
end
