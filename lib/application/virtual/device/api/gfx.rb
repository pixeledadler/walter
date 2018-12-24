# frozen_string_literal: true

module API
  # Comment
  module GFX
    include CommandAliases
    include BaseAPI

    # MENU/USER INTERFACE

    # 0x46 MENU-GFX
    def config(from: :gfx, to: :rad, arguments:)
      try(from, to, MENU_GFX, arguments)
    end
  end
end
