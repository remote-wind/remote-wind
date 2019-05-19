require 'rails_helper'

describe Services::Notifiers::LowBalance do
  describe '.call' do
    let(:station) { build_stubbed(:station, user: build_stubbed(:user)) }
    let(:mail) { ActionMailer::Base.deliveries.pop }
    let(:message) {  "#{station.name} has a low balance, only #{station.balance} kr left." }
    let(:logger) { Logger.new('/dev/null') }
    it "sends an email to the owner" do
      described_class.call(station)
      expect(mail.to.first).to eq station.user.email
      expect(mail.subject).to match  "Low balance for your station"
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
