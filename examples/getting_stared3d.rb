# frozen_string_literal: true

# https://gr-framework.org/c.html
require 'gr'

z = Array.new(100) { |i| i / 100.0 }
x = Array.new(100) { |i| i * Math.sin(i * Math::PI / 10.0) / 100.0 }
y = Array.new(100) { |i| i * Math.cos(i * Math::PI / 10.0) / 100.0 }

GR.clearws
GR.setwindow(-1, 1, -1, 1)
GR.polyline3d(x, y, z)
tick = GR.tick(0, 1)
GR.axes3d(tick, tick, tick, 0, 0, 0, 1, 1, 1, -0.001)
GR.updatews
gets
