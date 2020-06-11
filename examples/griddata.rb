# frozen_string_literal: true

# https://github.com/sciapp/gr/blob/master/examples/griddata.c

require 'gr'
require 'numo/narray'

DFloat = Numo::DFloat
DFloat.srand

xd = -2 + DFloat.new(100).rand * 4
yd = -2 + DFloat.new(100).rand * 4
zd = xd * Numo::NMath.exp(-xd * xd - yd * yd)

GR.setviewport(0.1, 0.95, 0.1, 0.95)
GR.setwindow(-2, 2, -2, 2)
GR.setmarkersize(1)
GR.setmarkertype(GR::MARKERTYPE_SOLID_CIRCLE)
GR.setcharheight(0.024)
GR.settextalign(2, 0)
GR.settextfontprec(3, 0)

x, y, z = GR.gridit(xd, yd, zd, 200, 200)
h = -0.6.step(0.6, 0.05).to_a
GR.contourf(x, y, h, z, 2)
GR.polymarker(xd, yd)
GR.axes(0.25, 0.25, -2, -2, 2, 2, 0.01)

GR.updatews
gets # wait
