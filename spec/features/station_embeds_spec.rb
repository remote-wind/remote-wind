feature "Station Embeds", %q[
  Each station should have embeds available in various styles ] do
  let! (:station) { create(:station) }

  scenario  "when I visit a station embed" do
      visit embed_station_path station
      expect(page.html).to_not match /<link/
  end

  scenario  "when I visit a station embed with css=true" do
    visit embed_station_path(station) + "?css=true"
    expect(page.html).to match /<link/
  end

  context "with type = chart" do
    scenario "when parameters contain height" do
      visit embed_station_path(station,  height: 300, type: "chart")
      expect(page).to have_selector "#station_measures_chart[height='300']"
    end
    scenario "when parameters contain width"do
      visit embed_station_path(station, width: 250, type: "chart")
      expect(page).to have_selector "#station_measures_chart[width='250']"
    end
  end

  context "with type = table" do
    scenario "when parameters contain height" do
      visit embed_station_path(station,  height: 300, type: "table")
      expect(page).to have_selector ".remote-wind-widget[height='300']"
    end
    scenario "when parameters contain width"do
      visit embed_station_path(station, width: 250, type: "table")
      expect(page).to have_selector ".remote-wind-widget[width='250']"
    end
  end
end