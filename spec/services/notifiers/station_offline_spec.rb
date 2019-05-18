require 'rails_helper'

describe Services::Notifiers::StationOffline do
  describe '.call' do
    let(:user) { build_stubbed(:user) }
    let(:station) { build_stubbed(:station, name: 'Monkey Island', user: user) }
    let(:mail) { ActionMailer::Base.deliveries.last }
    let(:message) { "Your station Monkey Island has not responded for 15 minutes." }
    let(:logger) { Logger.new('/dev/null') }
    it "sends an email to the owner" do
      described_class.call(station)
      expect(mail.to.first).to eq station.user.email
      expect(mail.subject).to eq message
    end
    it "creates a notification" do
      expect {
        described_class.call(station)
      }.to change(Notification, :count).by(+1)
    end
    it "logs a message" do
      expect(logger).to receive(:info).with(message)
      described_class.call(station, logger: logger)
    end
  end
end
