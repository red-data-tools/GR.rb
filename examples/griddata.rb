# frozen_string_literal: true

# https://github.com/sciapp/gr/blob/master/examples/griddata.c

require 'gr'
require 'numo/narray'

DFloat = Numo::DFloat

xd = -2 + DFloat.new(100).rand * 4
yd = -2 + DFloat.new(100).rand * 4
zd = xd * Numo::NMath.exp(-xd * xd - yd * yd)

h = -0.5 + DFloat.new(20).seq / 19.0

gr = GR::GR.new

gr.setviewport(0.1, 0.95, 0.1, 0.95)
gr.setwindow(-2.0, 2.0, -2.0, 2.0)
gr.setspace(-0.5, 0.5, 0, 90)
gr.setmarkersize(1.0)
gr.setmarkertype(-1)
gr.setcharheight(0.024)
gr.settextalign(2, 0)
gr.settextfontprec(3, 0)

gr.gridit(100, xd, yd, zd, 200, 200)
gr.surface(200, 200, 5)
gr.contour(200, 200, h, 0)
gr.polymarker(xd, yd)
gr.axes(0.25, 0.25, -2, -2, 2, 2, 0.01)

gr.updatews
gets # wait
