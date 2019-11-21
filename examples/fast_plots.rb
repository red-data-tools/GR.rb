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

x = DFloat.linspace(0, 10, 11)
y = NMath.sin(x)
GR.stepplot(x, y)
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

x = DFloat.linspace(0, 30, 1000)
y = NMath.cos(x) * x
z = NMath.sin(x) * x
GR.lineplot3(x, y, z)
gets

x = 2 * DFloat.new(100).rand - 1
y = 2 * DFloat.new(100).rand - 1
z = 2 * DFloat.new(100).rand - 1
GR.scatterplot3(x, y, z)
gets

c = 999 * DFloat.new(100).rand + 1
GR.scatterplot3(x, y, z, c)
gets

GR.histogram(DFloat.new(10_000).rand_norm)
gets

GR.barplot(%w[a b c d e], [1, 2, 3, 4, 5])
gets

GR.barplot(%w[a b c d e], [1, 2, 3, 4, 5], horizontal: true)
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
GR3.terminate
gets

x = 8 * DFloat.new(100).rand - 4
y = 8 * DFloat.new(100).rand - 4
z = NMath.sin(x) + NMath.cos(y)
GR.trisurfaceplot(x, y, z)
gets

x = 8 * DFloat.new(100).rand - 4
y = 8 * DFloat.new(100).rand - 4
z = NMath.sin(x) + NMath.cos(y)
GR.wireframe(x, y, z)
gets

_x = DFloat.linspace(-2, 2, 40)
_y = DFloat.linspace(0, Math::PI, 20)
x = _x.expand_dims(0) * DFloat.ones(_y.size, 1)
y = _y.expand_dims(1) * DFloat.ones(1, _x.size)
z = NMath.sin(x) + NMath.cos(y)
GR.wireframe(x, y, z)
gets

GR.volumeplot(DFloat.new(50, 50, 50).rand_norm)
gets

n = 1_000_000
x = DFloat.new(n).rand_norm
y = DFloat.new(n).rand_norm
GR.shade(x, y)
GR3.terminate
gets
