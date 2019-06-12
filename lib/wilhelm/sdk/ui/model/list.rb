# frozen_string_literal: true

module Wilhelm
  class UserInterface
    module Model
      # Comment
      class List
        DEFAULT_PAGE_SIZE = 10
        DEFAULT_INDEX = 0
        DEFAULT_OPTIONS = { page_size: DEFAULT_PAGE_SIZE, index: DEFAULT_INDEX }
        attr_accessor :page_size
        attr_reader :index
        def initialize(items_array, opts = DEFAULT_OPTIONS)
          @list_items = items_array
          @page_size = opts[:page_size]
        end

        def page
          @list_items[0, page_size]
        end

        def shift(i)
          @index = i
          @list_items.rotate!(i)
          index
        end
      end
    end
  end
end

# class View::List < TitledMenu
#   PAGE_SIZE_MAX = 8
#   ITEMS_PER_CELL = 1
# end