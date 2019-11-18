# frozen_string_literal: true

# https://github.com/sciapp/python-gr/blob/master/examples/contour.py
require 'gr'
require 'gr/plot'
require 'numo/narray'

data = File.readlines(File.expand_path('fecr.dat', __dir__)).map(&:to_f)

z = Numo::DFloat.cast(data).reshape(200, 200)
GR.contourfplot(z)
gets

z = Numo::DFloat.cast(data).reshape(200, 200)
GR.contourplot(z)
gets
