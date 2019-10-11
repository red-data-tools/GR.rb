# frozen_string_literal: true

# https://github.com/jheinen/GR.jl/blob/master/examples/shade_ex.jl

require 'gr'
require 'numo/narray'
DFloat = Numo::DFloat

n = 1_000_000
x = []
y = []

[[2, 2, 0.02],
 [2, -2, 0.1],
 [-2, -2, 0.5],
 [-2, 2, 1.0],
 [0, 0, 3.0]].each do |x_, y_, σ|
  x.concat DFloat.new(n).rand_norm(x_, σ).to_a
  y.condat DFloat.new(n).rand_norm(y_, σ).to_a
end

puts "#{x.length} of points: "

GR.setviewport(0.1, 0.95, 0.1, 0.95)
GR.setwindow(-10, 10, -10, 10)
GR.setcharheight(0.02)
GR.axes2d(0.5, 0.5, -10, -10, 4, 4, -0.005)
GR.setcolormap(GR::COLORMAP_HOT)

GR.shadepoints(x, y, xform: GR::XFORM_EQUALIZED)

GR.updatews
gets
