# frozen_string_literal: true

require 'gr'
require 'gr3'
require 'numo/narray'

data = Numo::UInt16.from_string(File.binread(File.expand_path('mri.raw', __dir__)))
                   .reshape(64, 64, 93)
data = data.transpose(2, 1, 0).to_a.flatten
data.map! { |i| i > 2000 ? 2000 : i }
data.map! { |i| (i / 2000.0 * Numo::UInt16::MAX).floor.to_i }
# data = Numo::UInt16.cast((data / 2000.0 * Numo::UInt16::MAX).floor)
data = Numo::UInt32.cast(data).reshape(93, 64, 64)

GR.setviewport(0, 1, 0, 1)
GR3.cameralookat(-3, 2, -2, 0, 0, 0, 0, 0, -1)

mesh = GR3.createisosurfacemesh(data, [2.0 / 63, 2.0 / 63, 2.0 / 92], [-1.0, -1.0, -1.0], 5000)
GR3.drawmesh(mesh, 1, [0, 0, 0], [0, 0, 1], [0, 1, 0], [1, 1, 1], [1, 1, 1])
GR.clearws
GR3.drawimage(0, 1, 0, 1, 500, 500, GR3::DRAWABLE_GKS)
GR.updatews
gets
GR3.terminate
