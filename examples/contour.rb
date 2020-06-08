# frozen_string_literal: true

# https://github.com/sciapp/python-gr/blob/master/examples/contour.py
require 'gr/plot'
require 'numo/narray'

assets_dir = File.expand_path('assets', __dir__)
data = File.readlines(File.join(assets_dir, 'fecr.dat')).map(&:to_f)

z = Numo::DFloat.cast(data).reshape(200, 200)
GR.contourf(z)
gets

z = Numo::DFloat.cast(data).reshape(200, 200)
GR.contour(z, backgroundcolor: 1, colormap: 4)
gets
