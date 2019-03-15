# frozen_string_literal: true

# Top level namespace
module Wolfgang
  # Default Wolfgang logger
  module Constants
    include LogActually::ErrorOutput

    NOTIFICATIONS = 'Notifications'
    NOTIFICATIONS_LISTENER = 'Notif. Listener'
    NOTIFICATIONS_INACTIVE = 'Notif. (Inactive)'
    NOTIFICATIONS_ACTIVE = 'Notif. (Active)'

    def logger
      LogActually.wolfgang
    end
  end
end
