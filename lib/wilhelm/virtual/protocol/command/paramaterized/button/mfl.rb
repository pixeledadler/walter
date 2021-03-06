# frozen_string_literal: false

module Wilhelm
  module Virtual
    class Command
      module Parameterized
        module Button
          # Command::Parameterized::Button::MFL
          class MFL < Button::Base
            # Interpolated BUTTON ---------------------------------------------

            def button
              return mode_tel if mode_tel?
              return button_tel if tel?
              button_seek
            end

            def pretty
              return pretty_mode_tel if mode_tel?
              return pretty_button_tel if tel?
              pretty_button_seek
            end

            # MODE (R/T) ------------------------------------------------------

            def mode_tel
              action.parameters[:mode_tel].ugly
            end

            def pretty_mode_tel
              action.parameters[:mode_tel].pretty
            end

            def mode_tel?
              return false if button_tel != :mfl_tel_null
              return false if button_seek != :mfl_seek_null
              true
            end

            alias rt? mode_tel?

            def mode
              case mode_tel
              when :mfl_rt_rad
                :rad
              when :mfl_rt_tel
                :tel
              end
            end

            def telephone_mode?
              return false unless mode_tel?
              return false if mode_tel == :mfl_rt_rad
              return true if mode_tel == :mfl_rt_tel
              true
            end

            alias mode? mode

            # BUTTON: TEL -----------------------------------------------------

            def button_tel
              action.parameters[:button_tel].ugly
            end

            def pretty_button_tel
              action.parameters[:button_tel].pretty
            end

            def tel?
              return false if button_tel == :mfl_tel_null
              button_seek == :mfl_seek_null
            end

            # BUTTON: SEEK -----------------------------------------------------

            def button_seek
              action.parameters[:button_seek].ugly
            end

            def pretty_button_seek
              action.parameters[:button_seek].pretty
            end

            def seek?
              return false if button_seek == :mfl_seek_null
              button_tel == :mfl_tel_null && button_seek != :mfl_seek_null
            end
          end
        end
      end
    end
  end
end
