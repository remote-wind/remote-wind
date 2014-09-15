require "spec_helper"
describe StationMailer do

  let(:station) { build_stubbed(:station, name: 'Monkey Island', user: user) }
  let(:args){ station }

  include_context 'multipart email'

  describe "#low_balance" do
    let(:method_name) { :low_balance }
    let(:subject_line) { "Low balance for your station Monkey Island" }
    it_behaves_like "a mailer"
    it "should have a link to station" do
      expect(html).to have_link(station.name, station_url(station))
    end
    it "contains the current balance" do
      expect(text).to have_content('Currently at 1.0 SEK')
    end
  end

  describe "#online" do
    let(:method_name) { :offline }
    let(:subject_line) { "Your station Monkey Island has not responded for 15 minutes." }
    it_behaves_like "a mailer"
    it "should have a link to station" do
      expect(html).to have_link(station.name, station_url(station))
    end
  end

  describe "#offline" do
    let(:method_name) { :offline }
    let(:subject_line) { "Your station Monkey Island has not responded for 15 minutes." }
    it_behaves_like "a mailer"
    it "should have a link to station" do
      expect(html).to have_link(station.name, station_url(station))
    end
  end
end

