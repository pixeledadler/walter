# frozen_string_literal: false

module Wilhelm
  module Virtual
    module Handler
      # Handler::DisplayHandler
      class DisplayHandler < Core::BaseHandler
        include Constants::Command::Aliases
        include Singleton

        NAME = 'Display'.freeze

        def self.i
          instance
        end

        def name
          NAME
        end

        def initialize
          enable
        end

        def inspect
          str_buffer = "<DisplayHandler>"
          str_buffer.concat("\nFilters:")
          str_buffer.concat("\n\tCommands: #{filtered_commands}")
          str_buffer.concat("\n\tTo: #{filtered_recipients}")
          str_buffer.concat("\n\tFrom: #{filtered_senders}")
        end

        def add_message(message)
          filtered_output(message)
        end

        def update(action, properties)
          LOGGER.debug(name) { "\t#update(#{action}, #{properties})" }
          case action
          when MESSAGE_RECEIVED
            message_received(properties)
          when EXIT
            LOGGER.info(name) { 'Exit: Disabling output.' }
            # hide the message output as it clutters the exit log messages
            disable
          end
        rescue StandardError => e
          LOGGER.error(name) { e }
          e.backtrace.each { |line| LOGGER.error(line) }
        end

        def message_received(properties)
          message = properties[:message]
          filtered_output(message)
        rescue StandardError => e
          LOGGER.error(name) { e }
          LOGGER.error(name) { message }
          e.backtrace.each { |l| LOGGER.error(name) { l } }
        end

        # ************************************************************************* #
        #                              OUTPUT CONTROL
        # ************************************************************************* #

        def disable
          LOGGER.info(name) { "Outout disabled." }
          @output_enabled = false
        end

        def enable
          LOGGER.debug(name) { "Output enabled." }
          @output_enabled = true
        end

        def output_enabled?
          @output_enabled
        end

        def exit(___)
          LOGGER.info(name) { 'Exit: Disabling output.' }
          # hide the message output as it clutters the exit log messages
          disable
        end

        # ************************************************************************* #
        #                              OUTPUT FILTERING
        # ************************************************************************* #

        def clear_filter
          LOGGER.info(name) { "Clearing filter..." }
          @filtered_commands = populate_commands
          @filtered_recipients = populate_devices
          @filtered_senders = populate_devices
          true
        end

        # ------------------------------ RECIPIENT ------------------------------ #

        def filter_to(*to_idents)
          LOGGER.info(name) { "Filter Recipients: #{to_idents}" }
          filtered_recipients.clear if filtered_recipients.size >= 5
          return false if filtered_recipients.any?  { |to_ident| @filtered_recipients.include?(to_ident) }
          to_idents.each { |to_ident| @filtered_recipients << to_ident }
          true
        end

        alias f_t filter_to

        # ------------------------------ SENDER ------------------------------ #

        def filter_from(*from_idents)
          LOGGER.info(name) { "Filter Senders: #{from_idents}" }
          filtered_senders.clear if filtered_senders.size >= 5
          return false if filtered_senders.any? { |from_ident| @filtered_senders.include?(from_ident) }
          from_idents.each { |from_ident| @filtered_senders << from_ident  }
          true
        end

        alias f_f filter_from

        # ------------------------------ COMMANDS ------------------------------ #

        def filter_commands(*command_ids)
          LOGGER.info(name) { "Filtering commands: #{command_ids}" }
          filtered_commands.clear if filtered_commands.size >= 5
          return false if command_ids.any? { |c_id| @filtered_commands.include?(c_id) }
          command_ids.each { |command_id| @filtered_commands << command_id }
          true
        end

        alias f_c filter_commands

        def hide_command_set(set)
          LOGGER.info(name) { 'Hiding command set...' }
          set.each do |group, command_ids|
            LOGGER.info(name) { "Hide: #{group} => #{command_ids}" }
            hide_commands(*command_ids)
          end
        end

        alias h_c_s hide_command_set

        def hide_commands(*command_ids)
          LOGGER.debug(name) { "Hiding commands: #{command_ids}" }
          command_ids.each { |command_id| filtered_commands.delete(command_id) }
          true
        end

        alias h_c hide_commands

        private

        # ************************************************************************* #
        #                              OUTPUT FILTERING
        # ************************************************************************* #

        def filtered_output(message)
          matches_a_command = filtered_commands.one? do |c|
            c == message.command.d
          end

          matches_a_recipient = filtered_recipients.one? do |c|
            c == message.to
          end

          matches_a_sender = filtered_senders.one? do |c|
            c == message.from
          end

          return false unless output_enabled?

          if matches_a_command && matches_a_recipient && matches_a_sender
            LOGGER.info(name) { message }
            return true
          else
            return false
          end
        end

        # ------------------------------ HELPERS ------------------------------ #

        def filtered_commands
          @filtered_commands ||= populate_commands
        end

        def filtered_recipients
          @filtered_recipients ||= populate_devices
        end

        def filtered_senders
          @filtered_senders ||= populate_devices
        end

        def populate_commands
          Array.new(256) { |i| i }
        end

        def populate_devices
          Map::AddressLookupTable.instance.idents
        end
      end
    end
  end
end
