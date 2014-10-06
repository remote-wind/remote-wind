require 'spec_helper'

describe ApplicationHelper, :type => :helper do

  describe "#title" do
    it "should return base title if there is no title" do
      expect(helper.title).to eq "Remote Wind"
    end

    it "should prepend @title" do
      @title = "Foo"
      expect(helper.title).to eq "Foo | Remote Wind"
    end
  end
end