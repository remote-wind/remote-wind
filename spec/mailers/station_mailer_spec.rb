require "spec_helper"
describe StationMailer do

  let(:station) { build_stubbed(:station, name: 'Monkey Island', user: user) }

  include_context 'multipart email'

  describe "#low_balance", method_name: 'low_balance' do

    let(:mail) { StationMailer.low_balance(station) }
    it_behaves_like "a mailer"
    it "has the correct subject" do
      expect(mail.subject).to eq "Low balance for your station Monkey Island"
    end
    it "should have a link to station" do
      expect(html).to have_link(station.name, station_url(station))
    end
    it "contains the current balance" do
      expect(text).to have_content('Currently at 1.0 SEK')
    end
  end

  describe "#online" do
    let(:mail) { StationMailer.online(station) }
    it "has the correct subject" do
      expect(mail.subject).to eq "Your station Monkey Island has started to respond and we are now receiving data from it."
    end
    it "should have a link to station" do
      expect(html).to have_link(station.name, station_url(station))
    end
  end

  describe "#offline" do
    let(:mail) { StationMailer.offline(station) }
    it "has the correct subject" do
      expect(mail.subject).to eq "Your station Monkey Island has not responded for 15 minutes."
    end
    it "should have a link to station" do
      expect(html).to have_link(station.name, station_url(station))
    end
  end
end

