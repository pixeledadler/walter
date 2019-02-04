# frozen_string_literal: true

module Wolfgang
  class UserInterface
    module View
      # Comment
      class BaseField
        attr_reader :id, :label, :arguments
        NO_PROPERTIES = {}.freeze

        def initialize(id: false, label:, properties: NO_PROPERTIES.dup)
          @id = id
          @label = label
          @properties = properties
        end

        def to_s
          label
        end
      end
    end
  end
end
