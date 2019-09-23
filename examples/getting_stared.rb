# https://gr-framework.org/c.html
require 'gr'

gr = GR::GR.new

x = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
y = [0.3, 0.5, 0.4, 0.2, 0.6, 0.7]

gr.polyline(x, y)
tick = gr.tick(0, 1)
gr.axes(tick, tick, 0, 0, 1, 1, -0.001)
gr.updatews
gets
