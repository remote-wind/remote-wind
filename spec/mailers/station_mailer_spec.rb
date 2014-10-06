require "spec_helper"
describe StationMailer, :type => :mailer do

  let(:user) { build_stubbed :user }
  let(:station) { build_stubbed(:station, name: 'Monkey Island', user: user) }
  let(:mail) { |example| StationMailer.send(example.metadata[:action], station) }

  include_context 'multipart email'

  describe "#low_balance", action: :low_balance do
    let(:subject_line) { "Low balance for your station Monkey Island" }
    it_behaves_like "a mailer"
    it "should have a link to station" do
      expect(html).to have_link(station.name, station_url(station))
    end
    it "contains the current balance" do
      expect(text).to have_content('Currently at 1.0 SEK')
    end

    context "when mail is not delivered" do
      before { allow_any_instance_of(Mail::Message).to receive(:deliver).and_return(false)}

      it "logs error if message is not delivered" do
        expect(Rails.logger).to receive(:error)
          .with("StationMailer#low_balance: Email could not be delivered")
        StationMailer.low_balance(station)
      end
    end
  end

  describe "#online", action: :online do
    let(:subject_line) { "Your station Monkey Island has not responded for 15 minutes." }
    it "should have a link to station" do
      expect(html).to have_link(station.name, station_url(station))
    end
  end

  describe "#offline", action: :offline do
    let(:subject_line) { "Your station Monkey Island has not responded for 15 minutes." }
    it "should have a link to station" do
      expect(html).to have_link(station.name, station_url(station))
    end
  end
end

