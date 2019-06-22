# frozen_string_literal: false

module Wilhelm
  module Virtual
    class Device
      module API
        # Comment
        module BaseAPI
          include Wilhelm::Core::Constants::Events
          include Observable
          include Helpers::Cluster
          include LogActually::ErrorOutput

          NAME = 'BaseAPI'.freeze

          def name
            NAME
          end

          def try(from, to, command_id, command_arguments = {})
            command_object = to_command(command_id: command_id,
              command_arguments: command_arguments,
              schema_from: from)

              send_it!(from, to, command_object)
            rescue StandardError => e
              LOGGER.error("#{self.class} StandardError: #{e}")
              e.backtrace.each { |l| LOGGER.error(l) }
              binding.pry
            end

            def send_it!(from, to, command)
              LOGGER.debug(name) { "#send_it!(#{from.sn(false)}, #{to.sn(false)}, #{command.inspect})" }
              message = Wilhelm::Core::Message.new(from, to, command)
              changed
              notify_observers(MESSAGE_SENT, message: message)
              true
            rescue StandardError => e
              LOGGER.error("#{self.class} StandardError: #{e}")
              e.backtrace.each { |l| LOGGER.error(l) }
              binding.pry
            end

            alias give_it_a_go try

            private

            def to_command(command_id:, command_arguments:, schema_from:)
              command_config = Wilhelm::Core::CommandMap.instance.config(command_id, schema_from)
              command_builder = command_config.builder
              command_builder = command_builder.new(command_config)
              command_builder.add_parameters(command_arguments)
              command_builder.result
            rescue StandardError => e
              with_backtrace(LOGGER, e)
            end

            def format_chars!(command_arguments, opts = { align: :center })
              chars_string = command_arguments[:chars]
              return false unless chars_string

              align(chars_string, opts[:align])

              chars_array = chars_string.bytes
              command_arguments[:chars] = chars_array
            end
          end
        end
    end
  end
end
