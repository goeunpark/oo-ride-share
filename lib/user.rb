module RideShare
  class User
    attr_reader :id, :name, :phone_number, :trips

    def initialize(input)
      if input[:id].nil? || input[:id] <= 0
        raise ArgumentError, 'ID cannot be blank or less than zero.'
      end

      @id = input[:id]
      @name = input[:name]
      @phone_number = input[:phone]
      @trips = input[:trips].nil? ? [] : input[:trips]
    end

    def add_trip(trip)
      @trips << trip
    end

    def net_expenditures
      total_cost = 0
      @trips.each do |trip|
        total_cost += trip.cost
      end
      return total_cost
    end

    def total_time_spent
      total_time = 0
      @trips.each do |trip|
        total_time += trip.duration
      end
      return total_time/60
    end

  end
end
