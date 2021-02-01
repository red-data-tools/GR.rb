# frozen_string_literal: true

require 'gr'
require_relative 'clifford_attractor'

n = 100_000_000
x, y = CliffordAttractor.calc(n)

GR.setviewport(0, 1, 0, 1)
GR.setwindow(-3, 3, -3, 3)
GR.setcolormap(8)
GR.shadepoints(x, y, dims: [480, 480], xform: 5)
GR.updatews
gets
