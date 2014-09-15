shared_examples "a station" do
  describe "attributes" do
    its(:id)        { should eq attributes[:id] }
    its(:latitude)  { should eq attributes[:latitude] }
    its(:longitude) { should eq attributes[:longitude] }
    its(:name)      { should eq attributes[:name] }
    its(:slug)      { should eq attributes[:slug] }
    its(:url)       { should include station_url(attributes[:slug]) }
    its(:path)      { should eq station_path(attributes[:slug]) }
    its(:offline) { should eq attributes[:offline] }
  end
end
