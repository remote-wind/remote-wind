require "spec_helper"



describe StationMailer do

  let(:station) { build_stubbed(:station, name: 'Monkey Island', user: user) }
  let(:args){ station }

  describe "#notify_about_low_balance" do

    let(:method_name) { :notify_about_low_balance }
    let(:subject_line) { "Low balance for your station Monkey Island" }

    it_behaves_like "a mailer"

  end

  describe "#notify_about_station_offline" do

    let(:method_name) { :notify_about_station_offline }
    let(:subject_line) { "Your station Monkey Island has not responded for 15 minutes." }

    it_behaves_like "a mailer"

  end

end

