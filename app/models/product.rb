require 'csv'
class Product < ActiveRecord::Base
  attr_accessible :name, :price, :released_on

  validates_presence_of :price

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      document = find_by_id(row["id"]) || new
      document.attributes = row.to_hash.slice(*accessible_attributes)
      document.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::CSV.new(file.path, nil, :ignore)
     when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
     when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
     else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.chart_data(start = 3.weeks.ago)
    total_prices = prices_by_day(start)
    (start.to_date..Date.today).map do |date|
      {
        released_on: date,
        price: total_prices[date] || 0,
      }
    end
  end

  def self.prices_by_day(start)
    products = where(released_on: start.beginning_of_day..Time.zone.now)
    products = products.group("date(released_on)")
    products = products.select("released_on, sum(price) as total_price")
    products.each_with_object({}) do |product, prices|
      prices[product.released_on.to_date] = product.total_price
    end
  end
end
