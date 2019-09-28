# frozen_string_literal: true

# https://github.com/jheinen/GR.jl/blob/master/examples/random_walk.jl

require 'gr'
require 'numo/narray'

y = Numo::DFloat.new(20, 500).rand_norm

GR.setviewport(0.1, 0.95, 0.1, 0.95)
GR.setcharheight(0.020)
GR.settextcolorind(82)
GR.setfillcolorind(90)
GR.setfillintstyle(1)

5000.times do |x|
  GR.clearws
  GR.setwindow(x, x + 500, -200, 200)
  GR.fillrect(x, x + 500, -200, 200)
  GR.setlinecolorind(0)
  GR.grid(50, 50, 0, -200, 2, 2)
  GR.setlinecolorind(82)
  GR.axes(50, 50, x, -200, 2, 2, -0.005)
  y = Numo::DFloat.hstack [y, Numo::DFloat.new(20, 1).rand_norm]
  20.times do |i|
    GR.setlinecolorind(980 + i)
    s = y[i, true].cumsum
    GR.polyline([*x..x + 500], s[x..x + 500])
  end
  GR.updatews
end
