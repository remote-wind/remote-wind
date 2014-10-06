shared_examples "a station" do
  describe "attributes" do
    it "has the correct id" do
      expect(subject.id).to eq attributes[:id]
    end
    it "has the correct latitude" do
      expect(subject.latitude).to eq attributes[:latitude]
    end
    it "has the correct latitude" do
      expect(subject.longitude).to eq attributes[:longitude]
    end
    it "has the correct name" do
      expect(subject.name).to eq attributes[:name]
    end
    it "has the correct slug" do
      expect(subject.slug).to eq attributes[:slug]
    end
    it "has the correct url" do
      expect(subject.url).to eq attributes[:url]
    end
    it "has the correct path" do
      expect(subject.path).to eq attributes[:path]
    end
    it "has the correct offline attribute" do
      expect(subject.offline).to eq attributes[:offline]
    end
  end
end
