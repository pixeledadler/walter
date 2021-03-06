# frozen_string_literal: false

module Wilhelm
  module Helpers
    # Helpers::Name
    module Name
      # Convert a symbol :name to instance variable name
      # @return [Instance Variable Name] :@variable_name
      def inst_var(name)
        name_string = name.id2name
        '@'.concat(name_string).to_sym
      end

      # Convert a symbol :name to class variable name
      # @return [Class Variable Name] :@@variable_name
      def class_var(name)
        name_string = name.id2name
        '@@'.concat(name_string).to_sym
      end

      # # Convert a symbol :name to class constant name
      # @return [Class Constant Name] :CONSTANT_NAME
      def class_const(name)
        name_string = name.upcase
        name_string.to_sym
      end

      def symbol_concat(*objects)
        objects.join&.to_sym
      end
    end
  end
end
