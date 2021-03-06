# frozen_string_literal: false

module Wilhelm
  module Helpers
    # Helpers::Module
    module Module
      SCOPE_DELIMITER = '::'.freeze

      # Retrieve a constant from a String i.e. "NameSpaceA::ClassX"
      def get_class(name)
        Kernel.const_get(name)
      end

      # @deprecated in favour of #join_namespaces
      def prepend_namespace(command_namespace, klass)
        return join_namespaces(command_namespace, klass)
        LOGGER.warn(self.class) { 'Deprecation Warning: #prepend_namespace' }
        "#{command_namespace}::#{klass}"
      end

      def join_namespaces(*constants)
        constants.join(SCOPE_DELIMITER)
      end
    end
  end
end
