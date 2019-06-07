# frozen_string_literal: true

class Walter
  class Audio
    # Comment
    class Target
      include Constants
      include Observable
      include Messaging::API

      PLAYER = 'Player'
      CONNECTED = 'Connected'

      attr_reader :attributes

      def initialize(attributes = {})
        @attributes = attributes
      end

      # ATTRIBUTES ------------------------------------------------------------

      def player
        attributes[PLAYER]
      end

      def connected
        attributes[CONNECTED]
      end

      def player_changed(new_player)
        attributes[PLAYER] = new_player
      end

      def player_added(new_player)
        attributes[PLAYER] = new_player
      end

      def player_removed(new_player)
        attributes[PLAYER] = new_player
      end

      # METHODS ---------------------------------------------------------------

      def volume_up
        volume_up!
      end

      def volume_down
        volume_down!
      end

      # UPDATE ------------------------------------------------------------

      def attributes!(new_object)
        changed = []
        attributes.merge!(new_object.attributes) do |key, old, new|
          changed << key
          old.is_a?(Hash) ? squish(old, new) : new
        end
        changed
        notify_observers(:updated, changed: changed, target: self)
      end

      def squish(old, new)
        old.merge(new)
      end
    end
  end
end
