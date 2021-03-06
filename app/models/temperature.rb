class Temperature < ActiveRecord::Base
	validates :fahrenheit, presence: true

	before_save :convert_units

  def convert_units(this = self)
    this.celsius = (this.fahrenheit - 32) * (5.0/9.0)
    this.kelvin = this.celsius + 273

    { celsius: this.celsius, kevlin: this.kelvin }
  end

  def self._convert_units(this = self)
    this.celsius = (this.fahrenheit - 32) * (5.0/9.0)
    this.kelvin = this.celsius + 273

    { celsius: this.celsius, kevlin: this.kelvin }
  end

  def self.aggregate_daily_temperatures
    aggregate_temperatures(1.day.ago, TemperatureAggregateDay)
  end

  def self.aggregate_weekly_temperatures
    aggregate_temperatures(7.day.ago, TemperatureAggregateWeek)
  end

  private

    def self.aggregate_temperatures(period, model)
      last_10_temperatures = Temperature.where('created_at > ?', period)

      if last_10_temperatures.count == 0
        return
      end

      daily_temperature = average_temperature(last_10_temperatures)

      model.create(fahrenheit: daily_temperature)
    end

    def self.average_temperature(temperatures)
      avg_temperature = 0

      temperatures.each do |temperature|
        avg_temperature += temperature.fahrenheit
      end

      avg_temperature /= temperatures.count
    end

    def self.delete_temperatures(temperatures)
      temperatures.each do |temperature|
        temperature.destroy
      end
    end
end
