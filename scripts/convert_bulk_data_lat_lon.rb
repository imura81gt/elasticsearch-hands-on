require 'csv'
require 'json'

ES_INDEX_NAME = 'gourmet'
ES_TYPE_NAME = 'restaurants'

row_csv = CSV.read('restaurants.csv')
header = row_csv.slice!(0)
data = row_csv

OUTPUT_FILENAME = 'bulk_restaurants_lat_lon.json'

File.delete(OUTPUT_FILENAME) if File.exist?(OUTPUT_FILENAME)
File.open(OUTPUT_FILENAME, 'a') do |file|
  data.each do |row|
    index = { index: { _index: ES_INDEX_NAME, _type: ES_TYPE_NAME, _id: row[0] } }
    file.puts(JSON.dump(index))
    hash = Hash[header.zip(row)]
    lon = ""
    lat = ""
    mod_hash = {}
    hash.each do |key, value|
      if key == "north_latitude" then
        value =~ /([0-9]+)\.([0-9]+)\.(.+)/
        lat = ($1.to_f + ($2.to_f / 60) +  ($3.to_f / 60**2)).to_s
      elsif key == "east_longitude" then
        value =~ /([0-9]+)\.([0-9]+)\.(.+)/
        lon = ($1.to_f + ($2.to_f / 60) +  ($3.to_f / 60**2)).to_s
      else
        mod_hash[key] =  value
      end
    end
    mod_hash["pin"] = {"lat" => lat, "lon" => lon}
    file.puts(JSON.dump(mod_hash))
  end
end
