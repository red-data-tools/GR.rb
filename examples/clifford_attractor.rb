# frozen_string_literal: true

require 'gr'

include Math

n = 100_000_000
x0 = 0
y0 = 0
a = -1.3
b = -1.3
c = -1.8
d = -1.9
dθ = 0.007

x = [x0]
y = [y0]
θ = 0.007

n.times do |i|
  x <<  (sin(a * y[i]) + c * cos(a * x[i])) * cos(θ)
  y <<  (sin(b * x[i]) + d * cos(b * y[i])) * cos(θ)
  θ += dθ
end

GR.setviewport(0, 1, 0, 1)
GR.setwindow(-3, 3, -3, 3)
GR.setcolormap(8)
GR.shadepoints(x, y, [480, 480], 5)
GR.updatews
gets
