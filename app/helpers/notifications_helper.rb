module NotificationsHelper

  # Get a array of html classes from Notification attributes
  # @param note Notification
  # @return array
  def notification_classes(note)
    classes = ["notification"]
    classes.push(note.event) if note.event?
    classes.push(note.level_to_s) if note.level?
    note.read ? classes.push("read") : classes.push("unread")
  end

  # Create link to inbox with number of notifications
  # @param user User
  # @param count int || nil
  # @param opts hash || nil
  # @return string - an anchor element
  def link_to_notifications(user, count=nil, opts = {})
    txt = "Inbox"
    txt += "(#{count})" unless count.to_i.zero?
    link_to txt, notifications_path, opts
  end

  # Create link to mark all as read
  # @param opts hash || nil
  # @return String - an anchor element
  def link_to_mark_all_as_read(user, opts = {})
    opts.merge!({
      method: :patch,
      class: 'button'
    })
    link_to "Mark all as read", notifications_path, opts
  end

  # Create link to destroy notification
  # @param note Notification
  # @return String - an anchor element
  def link_to_destroy_notification(note)
    link_to 'delete', notification_path(note), method: :delete
  end

  # Create timestamp for html5 <time> element
  # @param note Notification
  # @return String - a machine readable time string
  def notification_timestamp(note)
    time_date_hours_seconds( @user.to_local_time( note.created_at ) )
  end
end
