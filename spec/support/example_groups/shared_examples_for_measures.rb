shared_examples "a observation" do
  describe "attributes" do
    its(:id)              { should_not be_nil } # indicates a false postive!
    its(:id)              { should eq attributes[:id] }
    its(:station_id)      { should eq attributes[:station_id] }
    its(:speed)           { should eq attributes[:speed] }
    its(:direction)       { should eq attributes[:direction] }
    its(:max_wind_speed)  { should eq attributes[:max_wind_speed] }
    its(:min_wind_speed)  { should eq attributes[:min_wind_speed] }
    its(:created_at)      { should eq "1999-12-31T23:00:00Z" }
    its(:tstamp)          { should eq Time.new(2000).to_i }
  end
end