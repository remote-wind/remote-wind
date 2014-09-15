require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the MarkdownHelper. For example:
#
# describe MarkdownHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe MarkdownHelper do
  describe ".link_to" do
    it "creates a link" do
     expect(MarkdownHelper.link_to('Example', 'http://example.com')).to eq '[Example](http://example.com)'
    end
  end
end