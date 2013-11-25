require "spec_helper"

describe StationMailer do

  let(:user) { create(:user) }
  let(:station) { create(:station) }

  describe "notify_about_low_balance" do
    subject(:mail) { StationMailer.notify_about_low_balance(user, station)}

    its(:subject) { should eq("Low balance for your station #{station.name}") }
    its(:to) { should eq([user.email]) }

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "notify_about_station_down" do
    subject(:mail) { StationMailer.notify_about_station_down(user, station) }



    it "renders the headers" do
      mail.subject.should eq("Your station #{station.name} has not responded for 15 minutes.")
      mail.to.should eq([user.email])
      #mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
