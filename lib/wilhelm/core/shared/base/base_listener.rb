
# require 'event'

class Wilhelm::Core::BaseListener
  include Observable
  include Wilhelm::Core::Constants::Events
end
