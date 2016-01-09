class AddFirmwareVersionGsmSoftwareAndDescriptionToStations < ActiveRecord::Migration
  def change
    add_column :stations, :firmware_version, :string
    add_column :stations, :gsm_software, :string
    add_column :stations, :description, :string
  end
end
