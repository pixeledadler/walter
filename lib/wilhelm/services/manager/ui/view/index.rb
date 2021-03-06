# frozen_string_literal: true

module Wilhelm
  module Services
    class Manager
      class UserInterface
        module View
          # Manager::UserInterface::View::Index
          class Index < SDK::UIKit::View::BasicMenu
            include SDK::UIKit::View

            NO_DEVICES = [].freeze
            NO_OPTIONS = [].freeze

            def initialize(devices)
              @devices = indexed_devices(devices)
              # @options = indexed_options(model.options)
              @options = NO_OPTIONS
            end

            def menu_items
              @devices + @options + navigation_item
            end

            def reinitialize(devices)
              @devices = indexed_devices(devices)
            end

            private

            def navigation_item
              navigation(
                index: NAVIGATION_INDEX,
                label: 'Services Menu',
                action: :main_menu_index
              )
            end

            def indexed_devices(devices)
              return NO_DEVICES if devices.length.zero?
              validate(devices, COLUMN_ONE_MAX)

              devices.first(COLUMN_ONE_MAX).map.with_index do |device, index|
                indexed_device =
                CheckedItem.new(
                  id: device.id,
                  checked: device.connected?,
                  label: device.alias,
                  action: :bluetooth_device
                )
                [index, indexed_device]
              end
            end

            def indexed_options(options)
              return NO_OPTIONS if options.length.zero?
              validate(options, COLUMN_TWO_MAX)

              options.first(COLUMN_TWO_MAX).map.with_index do |option, index|
                [index + COLUMN_TWO_OFFSET, option]
              end
            end
          end
        end
      end
    end
  end
end
