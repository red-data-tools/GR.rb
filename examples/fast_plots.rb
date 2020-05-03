# frozen_string_literal: true

require 'gr/plot'
require 'numo/narray'
DFloat = Numo::DFloat
NMath = Numo::NMath

# Line Plots

x = DFloat.linspace(0, 10, 1001)
y = NMath.sin(x)
GR.plot(x, y)
sleep 1.2

x = DFloat.linspace(0, 10, 51)
y = NMath.sin(x)
GR.step(x, y)
sleep 1.2

angles = DFloat.linspace(0, 2 * Math::PI, 40)
radii = DFloat.linspace(0, 20, 40)
GR.polar(angles, radii)
sleep 1.2

x = DFloat.linspace(0, 30, 1000)
y = NMath.cos(x) * x
z = NMath.sin(x) * x
GR.plot3(x, y, z)
sleep 1.2

# Scatter Plots

x = DFloat.linspace(0, 1, 51)
y = x - x**2
z = x.clone * 200
GR.scatter(x, y, z)
sleep 1.2

x = DFloat.linspace(0, 1, 51)
y = x - x**2
sz = DFloat.linspace(50, 300, x.length)
c = DFloat.linspace(0, 255, x.length)
GR.scatter(x, y, sz, c)
sleep 1.2

x = 2 * DFloat.new(100).rand - 1
y = 2 * DFloat.new(100).rand - 1
z = 2 * DFloat.new(100).rand - 1
GR.scatter3(x, y, z)
sleep 1.2

x = 2 * DFloat.new(100).rand - 1
y = 2 * DFloat.new(100).rand - 1
z = 2 * DFloat.new(100).rand - 1
c = 999 * DFloat.new(100).rand + 1
GR.scatter3(x, y, z, c)
sleep 1.2

# Stem Plots

x = DFloat.linspace(-2, 2, 40)
y = x**3 + x**2 + x + 6
GR.stem(x, y)
sleep 1.2

# Bar Plots

GR.barplot(%w[a b c d e], [1, 2, 3, 4, 5])
sleep 1.2

GR.barplot(%w[a b c d e], [1, 2, 3, 4, 5], horizontal: true)
sleep 1.2

# Histograms

x = DFloat.new(10_000).rand_norm
GR.histogram(x)
sleep 1.2

x = DFloat.new(10_000).rand_norm
y = DFloat.new(10_000).rand_norm
GR.hexbin(x, y)
sleep 1.2

# Contour Plots

x1 = 8 * DFloat.new(100).rand - 4
y1 = 8 * DFloat.new(100).rand - 4
z1 = NMath.sin(x1) + NMath.cos(y1)

# FIXME
_x2 = DFloat.linspace(-2, 2, 40)
_y2 = DFloat.linspace(0, Math::PI, 20)
x2 = (_x2.expand_dims(0) * DFloat.ones(_y2.size, 1)).flatten
y2 = (_y2.expand_dims(1) * DFloat.ones(1, _x2.size)).flatten
z2 = NMath.sin(x2) + NMath.cos(y2)

GR.contour(x1, y1, z1)
sleep 1.2
GR.contour(x2, y2, z2)
sleep 1.2

GR.contourf(x1, y1, z1)
sleep 1.2
GR.contourf(x2, y2, z2)
sleep 1.2

GR.surface(x1, y1, z1)
sleep 1.2
GR.surface(x2, y2, z2)
sleep 1.2

GR.trisurf(x1, y1, z1)
sleep 1.2
GR.trisurf(x2, y2, z2)
sleep 1.2

GR.wireframe(x1, y1, z1)
sleep 1.2
GR.wireframe(x2, y2, z2)
sleep 1.2

# Volume Rendering

z = DFloat.new(50, 50, 50).rand_norm
GR.volume(z)
sleep 1.2
GR.volume(z.sort(axis: 0))
sleep 1.2
GR.volume(z.sort(axis: 1))
sleep 1.2
GR.volume(z.sort(axis: 2))
sleep 1.2

# Heatmaps

z = DFloat.new(100, 50).rand_norm
GR.heatmap(z)
sleep 1.2
GR.heatmap(z.sort(axis: 0))
sleep 1.2
GR.heatmap(z.sort(axis: 1))
sleep 1.2

n = 1_000_000
x = DFloat.new(n).rand_norm
y = DFloat.new(n).rand_norm
GR.shade(x, y)
sleep 1.2
