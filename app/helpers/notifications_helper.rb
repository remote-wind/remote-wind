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
  # @param count int || nil
  # @param opts hash || nil
  # @return string - an anchor element
  def link_to_notifications(count=nil, opts = {})
    txt = "Inbox"
    txt += "(#{count})" unless count.to_i.zero?
    link_to txt, notifications_path, opts
  end

  # Create link to mark all as read, button is disabled if there are no
  # @param count int || nil
  # @param opts hash || nil
  # @return string - an anchor element
  def link_to_mark_all_as_read(count = nil, opts = {})
    opts.merge!({
      method: :patch,
      class: 'button'
    })
    if count.nil?
      opts[:disabled] = true
      opts[:class] << ' disabled'
    end

    link_to "Mark all as read", mark_all_as_read_notifications_path, opts
  end

end