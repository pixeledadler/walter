# frozen_string_literal: false

module Wilhelm
  module Virtual
    class Device
      module API
        # API::BaseAPI
        module BaseAPI
          include Observable
          include Wilhelm::Core::Constants::Events::Multiplexing
          include Virtual::Constants::Command::Aliases
          include Helpers::Cluster
          include LogActually::ErrorOutput

          NAME = 'API::Base'.freeze
          LOG_BUILD_COMMAND = '#build_command'

          def resolve_ident(ident)
            Map::AddressLookupTable.instance.resolve_ident(ident)
          end

          def name
            NAME
          end

          # Build command from arguments
          def dispatch_raw_command(from, to, command_id, command_args = {})
            LOGGER.debug(name) { "#dispatch_raw_command(#{from}, #{to}, #{command_args})" }
            config = get_command_config(command_id, from, to)

            # 2. Arguments Hash to Command ----------------------------------------
            command_object = build_command(config, command_args)

            # HACK: idents were resolved before command_object was built,
            # so CommandMap was not loading schemas. Thus, if default
            # command had different parameters... it would break!
            # See BaseCommand::Raw and Multiplexer for more.
            from = resolve_ident(from)
            to = resolve_ident(to)

            dispatch_command(from, to, command_object)
          rescue StandardError => e
            LOGGER.error(name) { e }
            e.backtrace.each { |line| LOGGER.error(name) { line }  }
            binding.pry
          end

          alias try dispatch_raw_command

          # Dispatch message for command_object
          def dispatch_command(from, to, command)
            LOGGER.debug(name) { "#dispatch_command(#{from}, #{to}, #{command.inspect})" }
            message = Message.new(from, to, command)
            changed
            notify_observers(MESSAGE_SENT, message: message)
            true
          rescue StandardError => e
            LOGGER.error(name) { e }
            e.backtrace.each { |line| LOGGER.error(name) { line }  }
            binding.pry
          end

          alias give_it_a_go try

          private

          def get_command_config(command_id, from_ident, to_ident)
            Map::Command.instance.config(
              command_id,
              from: from_ident,
              to: to_ident
            )
          end

          # 2. Arguments Hash to Command ----------------------------------------

          def build_command(command_config, command_arguments)
            LOGGER.debug(name) { LOG_BUILD_COMMAND }
            command_builder = command_config.builder
            command_builder = command_builder.new(command_config)
            command_builder.add_parameters(command_arguments)
            command_builder.result
          rescue StandardError => e
            with_backtrace(LOGGER, e)
          end
        end
      end
    end
  end
end
