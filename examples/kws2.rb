# frozen_string_literal: true

# https://github.com/sciapp/python-gr/blob/master/examples/kws2.py

require 'gr'
require 'gr/plot'
require 'numo/narray'

data = File.readlines(File.expand_path('kws2.dat', __dir__))
data = data[70..-3].join.strip.split(/\s+/).map(&:to_f)
z = Numo::DFloat.cast(data).reshape(128, 128)
[3, 4].each do |c|
  GR.surfaceplot(z,
                 figsize: [6, 5],
                 rotation: 45, tilt: 78,
                 colormap: c,
                 xlabel: 'X',
                 ylabel: 'Y',
                 zlabel: 'Counts',
                 accelerate: false)
  gets
end
