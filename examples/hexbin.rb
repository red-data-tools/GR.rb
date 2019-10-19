# frozen_string_literal: true

require 'gr'
require 'numo/narray'

x = Numo::DFloat.new(6000).rand_norm
y = Numo::DFloat.new(6000).rand_norm

GR.clearws
GR.setviewport(0.1, 0.8, 0.2, 0.9)
GR.setwindow(-4, 4, -4, 4)
GR.setcolormap 21
GR.hexbin(x, y, 40)
GR.setviewport(0.825, 0.85, 0.2, 0.9)
GR.colorbar
GR.updatews
gets
