# frozen_string_literal: true

require 'gr'
require 'gr/plot' # will be removed

require 'numo/narray'
DFloat = Numo::DFloat

x = DFloat.linspace(0, 10, 1001)
y = Numo::NMath.sin(x)
GR.lineplot(x, y)
gets

x = DFloat.linspace(0, 1, 51)
y = x - x**2
z = x.clone * 200
GR.scatterplot(x, y, z)
gets

sz = DFloat.linspace(50, 300, x.length)
c = DFloat.linspace(0, 255, x.length)
GR.scatterplot(x, y, sz, c)
gets

GR.stemplot(x, y)
gets
