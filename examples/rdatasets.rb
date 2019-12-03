# frozen_string_literal: true

# RDatasets
# https://github.com/kojix2/rdatasets

require 'rdatasets'
require 'gr/plot'

passenger = RDatasets.datasets.AirPassengers
time = passenger.at(0).to_a
value = passenger.at(1).to_a

GR.plot(time, value,
        title: 'Air Passenger numbers from 1949 to 1961',
        ylabel: "Passenger numbers (1000's)",
        xlabel: 'Date')
sleep 1.5

volcano = RDatasets.datasets.volcano.to_matrix.to_a
GR.contour(volcano)
sleep 1.5
GR.contourf(volcano)
sleep 1.5
GR.surface(volcano)
sleep 1.5
