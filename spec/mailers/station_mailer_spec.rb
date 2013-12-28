require "spec_helper"

describe StationMailer do

  let(:user) { build_stubbed(:user) }
  let(:station) { build_stubbed(:station) }

  describe "notify_about_low_balance" do
    subject(:mail) { StationMailer.notify_about_low_balance(user, station)}

    its(:subject) { should match "Low balance for your station #{station.name}" }
    its(:to) { should eq([user.email]) }

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end

    it "sends email to recipient" do
      expect(ActionMailer::Base.deliveries).to include(mail)
    end

  end

  describe "notify_about_station_down" do
    subject(:mail) { StationMailer.notify_about_station_down(user, station) }

    its(:subject) { should match "Your station #{station.name} has not responded for 15 minutes." }
    its(:to) { should eq [user.email] }

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end

    it "sends email to recipient" do
      expect(ActionMailer::Base.deliveries).to include(mail)
    end

  end

end
