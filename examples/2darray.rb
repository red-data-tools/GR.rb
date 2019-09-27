# frozen_string_literal: true

# https://github.com/sciapp/gr/issues/39#issuecomment-301684973
require 'gr'
require 'numo/narray'

GR.setviewport(0.1, 0.8, 0.2, 0.9)
GR.setwindow(-0.5, 3.5, -0.5, 3.5)
GR.axes(1, 1, -0.5, -0.5, 1, 1, -0.01)
a = Numo::UInt32.new(16).seq
amin, amax = a.minmax
a = 1000 + 255 * (a - amin) / (amax - amin)
GR.setcolormap(1)

# TODO: report to sciapp
GR.cellarray(-0.5, 3.5, -0.5, 3.5, 4, 4, a)

GR.setviewport(0.825, 0.85, 0.2, 0.9)
GR.colorbar
GR.updatews
gets
