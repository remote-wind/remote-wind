module NotificationsHelper

  # Get a array of html classes from Notification attributes
  # @param note Notification
  # @return array
  def notification_classes note
    classes = ["notification"]
    classes.push(note.event) if note.event?
    classes.push(note.level_to_s) if note.level?
    note.read ? classes.push("read") : classes.push("unread")
  end

  # Create link to inbox with number of notifications
  # @param count int || nil
  def link_to_notifications count=nil
    txt = "Inbox"
    txt += "(#{count})" unless count.to_i.zero?
    link_to txt, notifications_path
  end

end