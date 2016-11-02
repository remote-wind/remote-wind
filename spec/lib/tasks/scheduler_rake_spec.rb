require 'rails_helper'

# Nothing fancy, just check that the right messages are sent.
describe "scheduler:send_alerts_about_down_stations" do
  include_context "rake"
  it "invokes Station.check_all_stations" do
    expect(Station).to receive(:check_all_stations)
    subject.invoke
  end
end

# Nothing fancy, just check that the right messages are sent.
describe "scheduler:send_alerts_about_low_balance_stations" do
  include_context "rake"
  it "invokes Station.check_all_stations" do
    expect(Station).to receive(:send_low_balance_alerts)
    subject.invoke
  end
end