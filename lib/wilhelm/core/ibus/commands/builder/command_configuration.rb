# frozen_string_literal: false

module Wilhelm
  module Core
    class CommandConfiguration
      include Helpers
      PROC = 'CommandConfig'.freeze

      MAP = :map
      SWITCH = :switch
      BIT_ARRAY = :bit_array
      TYPES = [MAP, BIT_ARRAY, SWITCH].freeze

      DEFAULT_COMMAND_NAMESPACE = 'Wilhelm::Core::Command'.freeze
      BASE_COMMAND_STRING = 'BaseCommand'.freeze
      PARAMETERIZED_COMMAND_STRING = 'ParameterizedCommand'.freeze

      BASE_COMMMAND_BUILDER_STRING = 'Wilhelm::Core::BaseCommandBuilder'.freeze
      PARAMETERIZED_COMMAND_BUILDER_STRING = 'Wilhelm::Core::ParameterizedCommandBuilder'.freeze

      WRAPPER = Wilhelm::Core::ParameterConfiguration

      attr_reader :id, :parameters, :normal_fucking_decimal

      def logger
        LogActually.core
      end

      def initialize(mapped_command)
        LOGGER.debug(PROC) { "#initialize" }
        LOGGER.debug(PROC) { "Command Configuration starting..." }
        @command_hash = mapped_command.dup
        # LOGGER.debug(PROC) { "#initialize: parsing command and parameters..." }
        parse_command(@command_hash)
        parse_parameters(parameters_hash) if has_parameters?
        # LOGGER.debug(PROC) { "#initialize: configured?" }
        configure_class unless configured?
        LOGGER.debug(PROC) { "Command Configuraging completed..." }
      end

      def inspect
        "<#{PROC} @id=#{id} @sn=#{sn} @klass=#{klass} @has_parameters=#{has_parameters?} @parameter_list=#{parameter_list}>"
      end

      def builder
        case
        when has_parameters? && is_base?
          get_class(BASE_COMMMAND_BUILDER_STRING)
        when has_parameters?
          get_class(PARAMETERIZED_COMMAND_BUILDER_STRING)
        else
          get_class(BASE_COMMMAND_BUILDER_STRING)
        end
      end

      def has_builder?
        @command_hash[:builder] ? true : false
      end

      def klass
        @klass ||= @command_hash[:klass]
      end

      def klass_constant
        full_klass_name = prepend_namespace(DEFAULT_COMMAND_NAMESPACE, klass)
        get_class(full_klass_name)
      end

      def parameter_list
        parameters_hash.keys
      end

      def index
        @command_hash[:index]
      end

      # Parameter Types

      def has_bit_arrays?
        return false unless has_parameters?
        parameters.any? { |name, data| data.type == BIT_ARRAY }
      end

      def properties_hash
        @command_hash[:properties]
      end

      def parameters_hash
        @command_hash[:parameters]
      end

      # Initialization -------------------------------------------------------

      def parse_command(mapped_command)
        command_id = @command_hash[:default_id]
        id_byte = Byte.new(:decimal, command_id)
        @command_hash[:id] = id_byte
        @id = id_byte
        @normal_fucking_decimal = command_id
      end

      def each_parameter
        parameters.each
      end

      def parse_parameters(mapped_parameters)
        @parameters = {}
        mapped_parameters.each do |name, data|
          new_parameter =
          case
          when data[:type] == BIT_ARRAY
            BitArrayParameterConfiguration.new(name, data)
          else
            ParameterConfiguration.new(name, data)
          end
          @parameters[name] = new_parameter
        end
      end

      # Class Properties -------------------------------------------------------

      def has_parameters?
        result = parameters_hash.nil? ? false : true
        # LOGGER.debug(PROC) { "#has_parameters? => #{result}" }
        result
      end

      def is_base?
        result = klass == BASE_COMMAND_STRING
        # LOGGER.debug(PROC) { "#is_base? => #{result}" }
        result
      end


      def is_parameterized?
        # result_constant = klass_constant.kind_of?(parameterized_command)nap
        # result_constant2 = parameterized_command.kind_of?(klass_constant)
        # LOGGER.debug(PROC) { "#{klass_constant}: Class: #{klass_constant.class}, Superclass: #{parameterized_command.superclass}" }
        # LOGGER.debug(PROC) { "#{klass_constant}.kind_of?(#{parameterized_command}) => #{result_constant}" }
        # LOGGER.debug(PROC) { "#{parameterized_command}.kind_of?(#{klass_constant}) => #{result_constant2}" }
        # klass == PARAMETERIZED_COMMAND_STRING
        result = klass_constant <= parameterized_command
        result = result.nil? ? false : result
        LOGGER.debug(PROC) { "#{klass_constant} <= #{parameterized_command} => #{result}" }
        result
      end

      def parameterized_command
        full_klass_name = prepend_namespace(DEFAULT_COMMAND_NAMESPACE, PARAMETERIZED_COMMAND_STRING)
        get_class(full_klass_name)
      end

      # Class Configuration -------------------------------------------------------

      def configure_class
        LOGGER.debug(PROC) { "#{sn}: Class Configuration beginning." }
        setup_class_variable
        setup_klass_parameters
        setup_parameter_accessor(:parameters)
        LOGGER.debug(PROC) { "#{sn}: Class Configuration completed." }
        true
      end

      def sn
        properties_hash[:short_name]
      end

      def configured_defined?
        result = klass_constant.class_variable_defined?(:@@configured)
        # LOGGER.debug(PROC) { "#configured_defined? => #{result}" }
        result
      end

      def configured?
        LOGGER.debug(PROC) { "#configured?" }
        if !has_parameters?
          LOGGER.debug(PROC) { "#{sn} has no parameters! Configuration not required." }
          true
        elsif is_base?
          LOGGER.debug(PROC) { "#{sn} is BaseCommand. Configuration not required." }
          true
        elsif is_parameterized?
          LOGGER.debug(PROC) { "#{sn} is, or ancesor of #{PARAMETERIZED_COMMAND_STRING}. Configuration always required." }
          false
        elsif configured_defined?
          LOGGER.debug(PROC) { "#{sn} @@configured defined. Configuration already completed." }
          true
        else
          LOGGER.debug(PROC) { "Defaulting to false. Configuration required." }
          false
        end
      end

      def setup_class_variable
        klass_constant.class_variable_set(:@@configured, true)
        # klass_constant.class_variable_set(:@@parameters, parameters_hash)
        # klass_constant.const_set(:DICTIONARY, {})
      end

      def setup_klass_parameters
        parameters.each do |name, param_config|
          setup_parameter_accessor(name)
        end
      end

      def setup_parameter_accessor(parameter)
        LOGGER.debug(PROC) { "Adding #{parameter} accessor" }
        klass_constant.class_eval do
          attr_accessor parameter
        end
      end

      # Object Configuration -------------------------------------------------------

      def configure(command_object)
        LOGGER.debug(PROC) { "Configure command #{command_object.class}" }
        command_object.instance_variable_set(inst_var(:parameters), parameter_list)
      end
    end
  end
end
