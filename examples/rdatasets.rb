# frozen_string_literal: true

# RDatasets
# https://github.com/kojix2/rdatasets

require 'rdatasets'
require 'gr/plot'

passenger = RDatasets.datasets.AirPassengers
time = passenger.at(0).to_a
value = passenger.at(1).to_a

opts = { title: 'Air Passenger numbers from 1949 to 1961',
         ylabel: "Passenger numbers (1000's)",
         xlabel: 'Date' }
GR.plot(time, value, opts)
sleep 1.5
GR.step(time, value, opts)
sleep 1.5
GR.stem(time, value, opts)
sleep 1.5
GR.barplot(time, value, opts)
sleep 1.5

volcano = RDatasets.datasets.volcano.to_matrix.to_a.transpose
opts = { title: "Auckland's Maunga Whau Volcano" }
GR.contour(volcano, opts)
sleep 1.5
GR.tricontour(volcano, opts)
sleep 1.5
GR.contourf(volcano, opts)
sleep 1.5
GR.heatmap(volcano, opts)
sleep 1.5
GR.surface(volcano, opts)
sleep 1.5
GR.trisurface(volcano, opts)
sleep 1.5
GR.wireframe(volcano, opts)
sleep 1.5
