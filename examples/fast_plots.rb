# frozen_string_literal: true

require 'gr'
require 'gr/plot' # will be removed

require 'numo/narray'
DFloat = Numo::DFloat
NMath = Numo::NMath

x = DFloat.linspace(0, 10, 1001)
y = NMath.sin(x)
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

GR.histogram(DFloat.new(10_000).rand_norm)
gets

x = DFloat.new(10_000).rand_norm
y = DFloat.new(10_000).rand_norm
GR.hexbinplot(x, y)
gets

x = 8 * DFloat.new(100).rand - 4
y = 8 * DFloat.new(100).rand - 4
z = NMath.sin(x) + NMath.cos(y)
GR.contourplot(x, y, z)
gets

_x = DFloat.linspace(-2, 2, 40)
_y = DFloat.linspace(0, Math::PI, 20)
x = _x.expand_dims(0) * DFloat.ones(_y.size, 1)
y = _y.expand_dims(1) * DFloat.ones(1, _x.size)
z = NMath.sin(x) + NMath.cos(y)
GR.contourplot(x, y, z)
gets

x = 8 * DFloat.new(100).rand - 4
y = 8 * DFloat.new(100).rand - 4
z = NMath.sin(x) + NMath.cos(y)
GR.contourfplot(x, y, z)
gets

_x = DFloat.linspace(-2, 2, 40)
_y = DFloat.linspace(0, Math::PI, 20)
x = _x.expand_dims(0) * DFloat.ones(_y.size, 1)
y = _y.expand_dims(1) * DFloat.ones(1, _x.size)
z = NMath.sin(x) + NMath.cos(y)
GR.contourfplot(x, y, z)
gets

x = 8 * DFloat.new(100).rand - 4
y = 8 * DFloat.new(100).rand - 4
z = NMath.sin(x) + NMath.cos(y)
GR.tricontourplot(x, y, z)
gets

x = 8 * DFloat.new(100).rand - 4
y = 8 * DFloat.new(100).rand - 4
z = NMath.sin(x) + NMath.cos(y)
GR.surfaceplot(x, y, z)
gets

_x = DFloat.linspace(-2, 2, 40)
_y = DFloat.linspace(0, Math::PI, 20)
x = _x.expand_dims(0) * DFloat.ones(_y.size, 1)
y = _y.expand_dims(1) * DFloat.ones(1, _x.size)
z = NMath.sin(x) + NMath.cos(y)
GR.surfaceplot(x, y, z)
gets
