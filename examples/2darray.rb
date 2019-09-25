# frozen_string_literal: true

# https://github.com/sciapp/gr/issues/39#issuecomment-301684973
require 'gr'
require 'numo/narray'

gr = GR::GR.new
gr.setviewport(0.1, 0.8, 0.2, 0.9)
gr.setwindow(-0.5, 3.5, -0.5, 3.5)
gr.axes(1, 1, -0.5, -0.5, 1, 1, -0.01)
a = Numo::UInt32.new(16).seq
amin, amax = a.minmax
a = 1000 + 255 * (a - amin) / (amax - amin)
gr.setcolormap(1)

# TODO: report to sciapp
gr.cellarray(-0.5, 3.5, 3.5, -0.5, 4, 4, 1, 1, 4, 4, a)

gr.setviewport(0.825, 0.85, 0.2, 0.9)
gr.colorbar
gr.updatews
gets
