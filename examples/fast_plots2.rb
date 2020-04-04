 # frozen_string_literal: true

require 'gr/plot'

require 'numo/narray'
DFloat = Numo::DFloat
NMath = Numo::NMath

x = DFloat.linspace(0, 10, 1001)
y1 = NMath.sin(x)
y2 = NMath.cos(x)
y3 = NMath.tan(x)
GR.plot([x, y1], [x, y2], [x, y3], ylim: [-1.2, 1.2])
sleep 1.2

x = DFloat.linspace(0, 10, 101)
y1 = NMath.sin(x)
y2 = NMath.cos(x)
y3 = NMath.tan(x)
GR.plot([x, y1, spec: 'b'], [x, y2, spec: 'g'],
        ylim: [-1.2, 1.2])
sleep 1.2

x = DFloat.linspace(0, 10, 101)
y1 = NMath.sin(x)
y2 = NMath.cos(x)
y3 = NMath.tan(x)
GR.plot([x, y1], [x, y2],
        spec: 'x',
        ylim: [-1.2, 1.2])
sleep 1.2

x = DFloat.linspace(0, 10, 101)
y1 = NMath.sin(x)
y2 = NMath.cos(x)
y3 = NMath.tan(x)
GR.plot([x, y1, 'h'], [x, y2, 'd'], [x, y3, 's'],
        ylim: [-1.2, 1.2])
sleep 1.2

x = DFloat.linspace(0, 10, 51)
y1 = NMath.sin(x)
y2 = NMath.cos(x)
y3 = NMath.tan(x)
GR.step([x, y1, spec: 'b'], [x, y2, spec: 'g'],
        ylim: [-1.2, 1.2])
sleep 1.2

x = DFloat.linspace(0, 10, 51)
y1 = NMath.sin(x)
y2 = NMath.cos(x)
y3 = NMath.tan(x)
GR.step([x, y1], [x, y2],
        ylim: [-1.2, 1.2],
        spec: 'r')
sleep 1.2

x = DFloat.linspace(-1.2, 1.2, 51)
y1 = x
y2 = x**2
y3 = x**3
sz = DFloat.linspace(50, 300, x.length)
c = DFloat.linspace(0, 255, x.length)
GR.scatter([x, y1, nil, c], [x, y2, nil, c], [x, y3, nil, c])
sleep 1.2

GR.scatter([x, y1, sz], [x, y2, sz], [x, y3, sz])
sleep 1.2

GR.scatter([x, y1, sz, c], [x, y2, sz, c], [x, y3, sz, c])
sleep 1.2

angles = Numo::DFloat.linspace(0, 2 * Math::PI, 40)
radii = Numo::DFloat.linspace(0, 20, 40)
GR.polar(*Array.new(20) { |i| [angles, radii + i] })
sleep 1.2

x = DFloat.linspace(0, 30, 1000)
y = NMath.cos(x) * x
z = NMath.sin(x) * x
GR.plot3(*Array.new(10) { |i| [x + i, y, z] })
sleep 1.2

GR.plot3(x, y, z, spec: 's')
sleep 1.2

x = DFloat.linspace(0, 30, 1000)
y = NMath.cos(x) * x
z = NMath.sin(x) * x
GR.plot3(*Array.new(3) { |i| [x + 4 * i, y, z, spec: %w[o s x][i]] })
sleep 1.2 

#
# x = 2 * DFloat.new(100).rand - 1
# y = 2 * DFloat.new(100).rand - 1
# z = 2 * DFloat.new(100).rand - 1
# GR.scatter3(x, y, z)
# sleep 1.2
#
# c = 999 * DFloat.new(100).rand + 1
# GR.scatter3(x, y, z, c)
# sleep 1.2
#
# GR.barplot(%w[a b c d e], [1, 2, 3, 4, 5])
# sleep 1.2
#
# GR.barplot(%w[a b c d e], [1, 2, 3, 4, 5], horizontal: true)
# sleep 1.2
#
# x = DFloat.new(10_000).rand_norm
# y = DFloat.new(10_000).rand_norm
# GR.hexbin(x, y)
# sleep 1.2
#
# x = 8 * DFloat.new(100).rand - 4
# y = 8 * DFloat.new(100).rand - 4
# z = NMath.sin(x) + NMath.cos(y)
# GR.contour(x, y, z)
# sleep 1.2
#
# _x = DFloat.linspace(-2, 2, 40)
# _y = DFloat.linspace(0, Math::PI, 20)
# x = (_x.expand_dims(0) * DFloat.ones(_y.size, 1)).flatten
# y = (_y.expand_dims(1) * DFloat.ones(1, _x.size)).flatten
# z = (NMath.sin(x) + NMath.cos(y)).flatten
# GR.contour(x, y, z)
# sleep 1.2
#
# GR.contourf(x, y, z)
# sleep 1.2
#
# GR.surface(x, y, z)
# GR3.terminate
# sleep 1.2
#
#

x = 8 * DFloat.new(100).rand - 4
y = 8 * DFloat.new(100).rand - 4
z = NMath.sin(x) + NMath.cos(y)
args = Array.new(3) {|i| [x, y, z + 2*i]}
GR.contour(*args)
sleep 1.2

GR.contourf(*args)
sleep 1.2

GR.tricont(*args)
sleep 1.2

GR.surface(*args)
sleep 1.2

GR.trisurf(*args)
sleep 1.2

GR.wireframe(*args)
sleep 1.2
#
# z = DFloat.new(50, 50, 50).rand_norm
# GR.volume(z)
# sleep 1.2
# GR.volume(z.sort(axis: 0))
# sleep 1.2
# GR.volume(z.sort(axis: 1))
# sleep 1.2
# GR.volume(z.sort(axis: 2))
# sleep 1.2
#
# n = 1_000_000
# x = DFloat.new(n).rand_norm
# y = DFloat.new(n).rand_norm
# GR.shade(x, y)
# GR3.terminate
# sleep 1.2
#
