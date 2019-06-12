# frozen_string_literal: false

# Comment
class CommandMap < BaseMap
  include Singleton
  PROC = 'CommandMap'.freeze

  COMMANDS_MAP_NAME = 'commands'.freeze
  DEFAULT_COMMAND_NAMESPACE = 'Command'.freeze

  def initialize(map = COMMANDS_MAP_NAME)
    super(map)
  end

  def self.reload!
    instance.reload!
  end

  def find_or_default(command_id, from = nil)
    LOGGER.debug(PROC) { "#find_or_default(#{command_id})" }
    mapped_result = nil

    begin
      mapped_result = find(command_id)
    rescue IndexError
      LOGGER.error(PROC) {
        "Command ID: #{command_id}, #{DataTools.d2h(command_id, true)} not found!" }
      mapped_result = find(:default)
      mapped_result[:id][:d] = command_id
    end

    if from
      schemas = mapped_result[:schemas]
      if schemas
        # puts 'breakable point'
        has_schema = schemas.include?(from)
      end
      if has_schema
        # puts 'breakable point'
        mapped_result = mapped_result[from]
      end
    end

    mapped_result[:default_id] = command_id

    command_configuration = CommandConfiguration.new(mapped_result)
    command_configuration
  end

  def config(command_id, from = nil)
    find_or_default(command_id, from)
  end
end
