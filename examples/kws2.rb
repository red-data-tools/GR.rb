# frozen_string_literal: true

# https://github.com/sciapp/python-gr/blob/master/examples/kws2.py

require 'gr/plot'
require 'numo/narray'

assets_dir = File.expand_path('assets', __dir__)
data = File.readlines(File.join(assets_dir, 'kws2.dat'))
data = data[70..-3].join.strip.split(/\s+/).map(&:to_f)
z = Numo::DFloat.cast(data).reshape(128, 128)
[3, 4].each do |c|
  GR.surface(z,
             figsize: [7, 6],
             rotation: 45, tilt: 20,
             colormap: c,
             xlabel: 'X',
             ylabel: 'Y',
             zlabel: 'Counts')
  gets
end
