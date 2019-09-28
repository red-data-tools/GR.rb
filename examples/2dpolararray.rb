# frozen_string_literal: true

require 'gr'
require 'numo/narray'

20.times do |i|
  GR.clearws
  GR.setviewport(0.1, 0.8, 0.2, 0.9)
  GR.setwindow(-2.5, 3.5, -2.5, 3.5)
  GR.axes(1, 1, -0.5, -0.5, 1, 1, -0.01)
  a = Numo::UInt32.new(21).seq
  amin, amax = a.minmax
  a = 1000 + 255 * (a - amin) / (amax - amin)
  GR.setcolormap(i)

  # TODO: report to sciapp
  GR.polarcellarray(0, 0, 0, 360, 0.2, 2, 3, 7, a)

  GR.setviewport(0.825, 0.85, 0.2, 0.9)
  GR.colorbar
  GR.updatews
  sleep 1
end