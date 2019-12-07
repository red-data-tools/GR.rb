# frozen_string_literal: true

require 'gr/plot'

require 'numo/narray'
DFloat = Numo::DFloat
NMath = Numo::NMath

x = DFloat.linspace(0, 10, 1001)
y = NMath.sin(x)
GR.plot(x, y)
sleep 1.2

x = DFloat.linspace(0, 10, 11)
y = NMath.sin(x)
GR.step(x, y)
sleep 1.2

x = DFloat.linspace(0, 1, 51)
y = x - x**2
z = x.clone * 200
GR.scatter(x, y, z)
sleep 1.2

sz = DFloat.linspace(50, 300, x.length)
c = DFloat.linspace(0, 255, x.length)
GR.scatter(x, y, sz, c)
sleep 1.2

GR.stem(x, y)
sleep 1.2

x = DFloat.linspace(0, 30, 1000)
y = NMath.cos(x) * x
z = NMath.sin(x) * x
GR.plot3(x, y, z)
sleep 1.2

x = 2 * DFloat.new(100).rand - 1
y = 2 * DFloat.new(100).rand - 1
z = 2 * DFloat.new(100).rand - 1
GR.scatter3(x, y, z)
sleep 1.2

c = 999 * DFloat.new(100).rand + 1
GR.scatter3(x, y, z, c)
sleep 1.2

GR.histogram(DFloat.new(10_000).rand_norm)
sleep 1.2

GR.barplot(%w[a b c d e], [1, 2, 3, 4, 5])
sleep 1.2

GR.barplot(%w[a b c d e], [1, 2, 3, 4, 5], horizontal: true)
sleep 1.2

x = DFloat.new(10_000).rand_norm
y = DFloat.new(10_000).rand_norm
GR.hexbin(x, y)
sleep 1.2

x = 8 * DFloat.new(100).rand - 4
y = 8 * DFloat.new(100).rand - 4
z = NMath.sin(x) + NMath.cos(y)
GR.contour(x, y, z)
sleep 1.2

_x = DFloat.linspace(-2, 2, 40)
_y = DFloat.linspace(0, Math::PI, 20)
x = (_x.expand_dims(0) * DFloat.ones(_y.size, 1)).flatten
y = (_y.expand_dims(1) * DFloat.ones(1, _x.size)).flatten
z = (NMath.sin(x) + NMath.cos(y)).flatten
GR.contour(x, y, z)
sleep 1.2

GR.contourf(x, y, z)
sleep 1.2

GR.surface(x, y, z)
GR3.terminate
sleep 1.2

GR.wireframe(x, y, z)
sleep 1.2

x = 8 * DFloat.new(100).rand - 4
y = 8 * DFloat.new(100).rand - 4
z = NMath.sin(x) + NMath.cos(y)
GR.contourf(x, y, z)
sleep 1.2

GR.tricontour(x, y, z)
sleep 1.2

GR.surface(x, y, z)
sleep 1.2

GR.trisurface(x, y, z)
sleep 1.2

GR.wireframe(x, y, z)
sleep 1.2

z = Numo::DFloat.new(100, 50).rand_norm
GR.heatmap(z)
sleep 1.2
GR.heatmap(z.sort(axis: 0))
sleep 1.2
GR.heatmap(z.sort(axis: 1))
sleep 1.2

z = DFloat.new(50, 50, 50).rand_norm
GR.volume(z)
sleep 1.2
GR.volume(z.sort(axis: 0))
sleep 1.2
GR.volume(z.sort(axis: 1))
sleep 1.2
GR.volume(z.sort(axis: 2))
sleep 1.2

n = 1_000_000
x = DFloat.new(n).rand_norm
y = DFloat.new(n).rand_norm
GR.shade(x, y)
GR3.terminate
sleep 1.2
