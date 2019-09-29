# frozen_string_literal: true

# https://github.com/sciapp/gr/blob/master/examples/griddata.c

require 'gr'
require 'numo/narray'

DFloat = Numo::DFloat

xd = -2 + DFloat.new(100).rand * 4
yd = -2 + DFloat.new(100).rand * 4
zd = xd * Numo::NMath.exp(-xd * xd - yd * yd)

h = -0.5 + DFloat.new(20).seq / 19.0

GR.setviewport(0.1, 0.95, 0.1, 0.95)
GR.setwindow(-5.0, 5.0, -5.0, 5.0)
GR.setspace(-0.5, 0.5, 0, 90)
GR.setmarkersize(1.0)
GR.setmarkertype(-1)
GR.setcharheight(0.024)
GR.settextalign(2, 0)
GR.settextfontprec(3, 0)

x, y, z = GR.gridit(xd, yd, zd, 200, 200)
GR.surface(x, y, z, 5)
GR.contour(x, y, h, z, 0)
GR.polymarker(xd, yd)
GR.axes(0.25, 0.25, -2, -2, 2, 2, 0.01)

GR.updatews
gets # wait
