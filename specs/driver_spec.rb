require_relative 'spec_helper'

describe "Driver class" do

  describe "Driver instantiation" do
    before do
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ", phone: '111-111-1111', status: :AVAILABLE)
      end

      it "is an instance of Driver" do
        expect(@driver).must_be_kind_of RideShare::Driver
      end

      it "throws an argument error with a bad ID value" do
        expect{ RideShare::Driver.new(id: 0, name: "George", vin: "33133313331333133")}.must_raise ArgumentError
      end

      it "throws an argument error with a bad VIN value" do
        expect{ RideShare::Driver.new(id: 100, name: "George", vin: "")}.must_raise ArgumentError
        expect{ RideShare::Driver.new(id: 100, name: "George", vin: "33133313331333133extranums")}.must_raise ArgumentError
      end

      it "sets driven_trips to an empty array if not provided" do
        expect(@driver.driven_trips).must_be_kind_of Array
        expect(@driver.driven_trips.length).must_equal 0
      end

      it "is set up for specific attributes and data types" do
        [:id, :name, :vin, :status, :driven_trips].each do |prop|
          expect(@driver).must_respond_to prop
        end

        expect(@driver.id).must_be_kind_of Integer
        expect(@driver.name).must_be_kind_of String
        expect(@driver.vin).must_be_kind_of String
        expect(@driver.status).must_be_kind_of Symbol
      end
    end

    describe "add_driven_trip method" do
      before do
        pass = RideShare::User.new(id: 1, name: "Ada", phone: "412-432-7640")
        @driver = RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678")
        @trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: pass, date: "2016-08-08", rating: 5})
      end

      it "throws an argument error if trip is not provided" do
        expect{ @driver.add_driven_trip(1) }.must_raise ArgumentError
      end

      it "increases the trip count by one" do
        previous = @driver.driven_trips.length
        @driver.add_driven_trip(@trip)
        expect(@driver.driven_trips.length).must_equal previous + 1
      end
    end

    describe "Calculates average rating" do
      before do
        @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")
        trip = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil, date: Time.parse("2016-08-08"), rating: 5)
        @driver.add_driven_trip(trip)
      end

      it "returns a float" do
        expect(@driver.average_rating).must_be_kind_of Float
      end

      it "returns a float within range of 1.0 to 5.0" do
        average = @driver.average_rating
        expect(average).must_be :>=, 1.0
        expect(average).must_be :<=, 5.0
      end

      it "returns zero if no driven_trips" do
        driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ")
        expect(driver.average_rating).must_equal 0
      end

      it "correctly calculates the average rating" do
        trip2 = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil, date: Time.parse("2016-08-08"), rating: 1)
        @driver.add_driven_trip(trip2)
        expect(@driver.average_rating).must_be_close_to (5.0 + 1.0) / 2.0, 0.01
      end

      it "ignores adding to rating for a trip in progress" do
        trip = RideShare::Trip.new({id: 12, driver: @driver, passenger: pass, rating: nil, cost: nil})
        @driver.add_driven_trip(trip)
        expect(@driver.average_rating).must_be_close_to (5.0) / 1.0, 0.01
      end

    end

    describe "Calculates total revenue" do

      before do
        # pass = RideShare::User.new(id: 1, name: "Ada", phone: "412-432-7640")
        @driver = RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678")
        @trip1 = RideShare::Trip.new({id: 8, driver: @driver, passenger: pass, date: "2016-08-08", rating: 5, cost: 12})
        @trip2 = RideShare::Trip.new({id: 9, driver: @driver, passenger: pass, date: "2016-08-08", rating: 5, cost: 15})
        @trip3 = RideShare::Trip.new({id: 10, driver: @driver, passenger: pass, date: "2016-08-08", rating: 5, cost: 10})

        @driver.add_driven_trip(@trip1)
        @driver.add_driven_trip(@trip2)
        @driver.add_driven_trip(@trip3)
      end

      it "accurately calculates the total_revenue" do
        expect(@driver.total_revenue).must_equal 25.64
      end

      it "returns a float" do
        expect(@driver.total_revenue).must_be_instance_of Float
      end

      it "ignores a trip in progress" do
        trip = RideShare::Trip.new({id: 12, driver: @driver, passenger: pass, rating: nil, cost: nil})
        @driver.add_driven_trip(trip)
        expect(@driver.total_revenue).must_equal 25.64
      end

    end

    describe "Calculates net expenditures" do
      before do
        @driver = RideShare::Driver.new(id:1, name: "Lovelace", phone: "353-533-5334", vin: "12345678912345678")
        @trip1 = RideShare::Trip.new({id: 8, driver: pass, passenger: @driver, rating: 5, cost: 10})
        @trip2 = RideShare::Trip.new({id: 9, driver: pass, passenger: @driver, rating: 5, cost: 11})
        @trip3 = RideShare::Trip.new({id: 10, driver: @driver, passenger: pass, rating: 5, cost: 10})

        @driver.add_trip(@trip1)
        @driver.add_trip(@trip2)
        @driver.add_driven_trip(@trip3)
      end

      it "accurately calculates net_expenditures of a driver" do
        expect(@driver.net_expenditures).must_equal 14.32
      end

      it "returns a float" do
        expect(@driver.net_expenditures).must_be_instance_of Float
      end

      it "ignores adding to net_expenditures for a trip in progress" do
        trip = RideShare::Trip.new({id: 12, driver: @driver, passenger: pass, rating: nil, cost: nil})
        @driver.add_driven_trip(trip)
        expect(@driver.net_expenditures).must_equal 14.32
      end

    end


    describe "Accepts a trip in progress" do
      before do
        @passenger = RideShare::User.new(id: 1, name: "Ada", phone: "412-432-7640")
          @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV", vin: "1C9EVBRM0YBC564DZ", phone: '111-111-1111', status: :AVAILABLE)
          @trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: @passenger, date: "2016-08-08", rating: nil, cost: nil})
        end

        it "changes driver status from available to unavailable" do
          @driver.accept_trip(@trip)
          expect(@driver.status).must_equal :UNAVAILABLE
        end

        it "driver.trips now includes the new trip " do
          @driver.accept_trip(@trip)
          expect(@driver.driven_trips.last).must_equal @trip
        end
      end

  end
