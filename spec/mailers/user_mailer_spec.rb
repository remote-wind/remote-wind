require "spec_helper"

describe UserMailer do
  describe "test" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.test(user) }

    it "renders the headers" do
      mail.subject.should eq("Test")
      mail.to.should eq([user.email])
      mail.from.should eq([ENV['REMOTE_WIND_DEFAULT_FROM_EMAIL']])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
