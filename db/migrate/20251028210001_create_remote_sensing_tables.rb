# Remote Sensing and Precision Agriculture Integration
# Based on conceptual materials from issue #58 - ontological approach to precision farming
# References: Yakushev V.V., Borgest N.M. papers on precision agriculture
class CreateRemoteSensingTables < ActiveRecord::Migration[8.1]
  def change
    # FieldZones - differentiated field zones for precision agriculture
    create_table :field_zones do |t|
      t.references :farm, foreign_key: true, null: false
      t.string :name, null: false
      t.text :geometry # GeoJSON polygon
      t.float :area # hectares
      t.string :soil_type
      t.float :elevation
      t.text :characteristics # JSON - pH, organic matter, etc.
      t.string :productivity_class # high, medium, low based on NDVI analysis

      t.timestamps
    end

    # RemoteSensingData - satellite and drone data for precision agriculture (ДЗЗ)
    create_table :remote_sensing_data do |t|
      t.references :field_zone, foreign_key: true
      t.references :crop, foreign_key: true
      t.references :farm, foreign_key: true

      t.integer :source_type, null: false # 0: satellite, 1: drone, 2: ground_sensor
      t.integer :data_type, null: false # 0: multispectral, 1: thermal, 2: ndvi, 3: soil_moisture, 4: temperature
      t.string :source_name # e.g., "VEGA-Pro", "Resurs-P", "Geokan 201 Agro"
      t.datetime :captured_at, null: false
      t.text :data # JSON - actual measurements
      t.text :metadata # JSON - resolution, cloud cover, etc.
      t.float :ndvi_value # Normalized Difference Vegetation Index
      t.float :confidence_score # data quality indicator

      t.timestamps
    end

    # WeatherData - weather conditions for agro modeling
    create_table :weather_data do |t|
      t.references :farm, foreign_key: true
      t.references :field_zone, foreign_key: true

      t.datetime :recorded_at, null: false
      t.float :temperature # Celsius
      t.float :humidity # percentage
      t.float :precipitation # mm
      t.float :wind_speed # m/s
      t.integer :wind_direction # degrees
      t.float :solar_radiation # W/m²
      t.float :soil_temperature # Celsius
      t.float :soil_moisture # percentage
      t.string :source # weather station, API, sensor
      t.text :forecast_data # JSON - future predictions

      t.timestamps
    end

    # Indexes for efficient querying
    add_index :field_zones, [:farm_id, :productivity_class]
    add_index :remote_sensing_data, [:farm_id, :captured_at]
    add_index :remote_sensing_data, [:crop_id, :data_type]
    add_index :remote_sensing_data, [:source_type, :captured_at]
    add_index :weather_data, [:farm_id, :recorded_at]
  end
end
