# frozen_string_literal: true

require 'gr'

xd = [3, 3, 10, 18, 18, 10, 10, 5, 1, 15, 20, 5, 15, 10, 7, 13, 16]
yd = [3, 18, 18, 3, 18, 10, 1, 5, 10, 5, 10, 15, 15, 15, 20, 20, 8]
zd = [25, 25, 25, 25, 25, -5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 25]

GR.setviewport(0.1, 0.9, 0.1, 0.9)
GR.setwindow(0.0, 20.0, 0.0, 20.0)
GR.setcharheight(0.027)
GR.settextalign(2, 0)
GR.settextfontprec(3, 0)
GR.text(0.5, 0.96, 'DEMONSTRATION PLOT FOR RANDOM CONTOURS')
GR.selntran(1)
GR.setspace(-10.0, 40.0, 0, 90)
GR.axes(1.0, 1.0, 0.0, 0.0, 5, 5, -0.01)
GR.setwindow(0, 20, 0, 20)
GR.setspace(-10, 40, 0, 90)

x, y, z = GR.gridit(xd, yd, zd, 40, 40)
h = -4.step(28, 2).to_a
GR.contour(x, y, h, z, 0)

GR.updatews
gets
