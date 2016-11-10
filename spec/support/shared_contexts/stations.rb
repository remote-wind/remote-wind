RSpec.shared_context "Stations" do
  def one_of_each_status(**kwargs)
    Station.statuses.keys.each_with_object({}) do |key, hash|
      hash[key.to_sym] = create(:station, { status: key }.merge(kwargs) )
    end
  end
end
