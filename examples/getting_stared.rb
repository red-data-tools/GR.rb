# frozen_string_literal: true

# https://gr-framework.org/c.html
require 'gr'

x = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
y = [0.3, 0.5, 0.4, 0.2, 0.6, 0.7]

GR.polyline(x, y)
tick = GR.tick(0, 1)
GR.axes(tick, tick, 0, 0, 1, 1, -0.001)
GR.updatews
gets
