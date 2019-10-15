# frozen_string_literal: true

# https://github.com/sciapp/python-gr/blob/master/examples/spring_pendulum.py

require 'gr'
require 'gr3'
include Math

GR.setviewport(0, 1, 0, 1)
GR3.setbackgroundcolor(1, 1, 1, 1)

200.times do |t|
  f = 0.0375 * (cos(t * 0.2) * 0.995**t + 1.3)
  n = 90
  points = Array.new(n - 5) do |i|
    [sin(i * PI / 8), n * 0.035 - i * f, cos(i * PI / 8)]
  end
  points << [0, points[-1][1], 0]
  points << [0, points[-1][1] - 0.5, 0]
  points << [0, points[-1][1] - 1, 0]
  points.unshift [0, points[0][1], 0]
  points.unshift [0, points[0][1] + 2, 0]
  colors = [1, 1, 1] * n
  radii = [0.1] * n
  GR3.clear
  GR3.drawtubemesh(n, points, colors, radii)
  GR3.drawspheremesh(1, points[-1], colors, [0.75])
  GR.clearws
  GR3.drawimage(0, 1, 0, 1, 500, 500, GR3::DRAWABLE_GKS)
  GR.updatews
end
gets
