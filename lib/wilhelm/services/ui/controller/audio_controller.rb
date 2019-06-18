# frozen_string_literal: false

module Wilhelm
  class UserInterface
    module Controller
      # Comment
      class AudioController < BASE_CONTROLLER
        NAME = 'AudioController'

        attr_reader :addressed_player
        alias player addressed_player

        def name
          NAME
        end

        # 'Pages' ------------------------------------------------------

        def index
          LogActually.ui.debug(NAME) { '#index' }
          view = View::Audio::Index.new(addressed_player)
          view.add_observer(self)
          render(view)
        end

        def now_playing
          LogActually.ui.debug(NAME) { '#now_playing' }
          view = View::Audio::NowPlaying.new(addressed_player)
          view.add_observer(self)
          render(view)
        end

        # MENU ---------------------------------------------------------------

        # def notify
        #   LogActually.ui.debug(NAME) { '#notify' }
        #   2.times { bombs_away; Kernel.sleep(2.5) }
        # end
        #
        # def bombs_away
        #   LogActually.ui.debug(NAME) { '#bombs_away' }
        #   view = View::NotificationHeader.new(
        #     [Random.rand(97..97+26).chr,
        #      Random.rand(97..97+26).chr,
        #      Random.rand(97..97+26).chr,
        #      Random.rand(97..97+26).chr,
        #      Random.rand(97..97+26).chr,
        #      Random.rand(97..97+26).chr,
        #      Random.rand(97..97+26).chr]
        #    )
        #   # view.add_observer(self)
        #   renderer.render_new_header(view)
        # end

        # Setup ------------------------------------------------------

        def create(view)
          LogActually.ui.debug(NAME) { "#create(#{view})" }
          case view
          when :index
            @addressed_player = context.audio.player
            addressed_player.add_observer(self, :player_update)
            true
          when :now_playing
            @addressed_player = context.audio.player
            addressed_player.add_observer(self, :playback_update)
            true
          else
            LogActually.ui.warn(NAME) { "Create: #{view} view not recognised." }
            false
          end
        end

        def destroy
          LogActually.ui.debug(NAME) { "#destroy(#{loaded_view})" }
          case loaded_view
          when :index
            @addressed_player.delete_observer(self)
            @addressed_player = nil
            true
          when :now_playing
            @addressed_player.delete_observer(self)
            @addressed_player = nil
            true
          else
            LogActually.ui.warn(NAME) { "Destroy: #{loaded_view} view not recognised." }
            false
          end
        end

        # USER EVENTS ------------------------------------------------------

        # selected_menu_item may just be button state for non data request
        def update(action, selected_menu_item = nil)
          LogActually.ui.debug(NAME) { "#update(#{action}, #{selected_menu_item.id || selected_menu_item})" } if selected_menu_item
          LogActually.ui.debug(NAME) { "#update(#{action})" } unless selected_menu_item
          case action
          when :main_menu_index
            # destroy(:index)
            # context.ui.root.load(:index)
            ui_context.launch(:services, :index)
          when :audio_now_playing
            # destroy(:index)
            # load(:now_playing)
            ui_context.launch(:audio, :now_playing)
          when :audio_index
            # destroy(:now_playing)
            # load(:index)
            ui_context.launch(:audio, :index)
          when :audio_play
            context.audio.play!
          when :audio_pause
            context.audio.pause!
          else
            LogActually.ui.debug(NAME) { "#update: #{action} not implemented." }
          end
        end

        # DATA EVENTS ------------------------------------------------------

        def playback_update(action, player:)
          LogActually.ui.debug('AudioController') { "#playback_update(#{action}, #{player})" }
          case action
          when :track_change
            now_playing
          when :status
            now_playing
          end
        end

        def player_update(action, player:)
          LogActually.ui.debug('AudioController') { "#player_update(#{action}, #{player})" }
          case action
          when :track_change
            index
          when :status
            index
          end
        end
      end
    end
  end
end