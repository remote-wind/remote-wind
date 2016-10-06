# Used for the text/plain segment of multipart emails.
module MarkdownHelper
  # Used when parsing to create email friendly links
  # @return [String]
  def MarkdownHelper.link_to(name, url)
    "[#{name}](#{url})"
  end
end
