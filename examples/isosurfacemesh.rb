# frozen_string_literal: true

require 'gr'
require 'gr3'
require 'numo/narray'

assets_dir = File.expand_path('assets', __dir__)
data = Numo::UInt16.from_string(File.binread(File.join(assets_dir, 'mri.raw')))
                   .reshape(64, 64, 93)
data[data > 2000] = 2000
data = Numo::UInt16.cast((data / 2000.0 * Numo::UInt16::MAX).floor)

GR.setviewport(0, 1, 0, 1)
GR3.cameralookat(-3, 2, -2, 0, 0, 0, 0, 0, -1)

isolevels = Numo::UInt16.linspace(0, Numo::UInt16::MAX, 250)
isolevels.concatenate(isolevels.reverse).each do |isolevel|
  GR3.clear
  GR.clearws
  mesh = GR3.createisosurfacemesh(data, [2.0 / 63, 2.0 / 63, 2.0 / 92], [-1.0, -1.0, -1.0], isolevel)
  GR3.drawmesh(mesh, 1, [0, 0, 0], [0, 0, 1], [0, 1, 0], [1, 1, 1], [1, 1, 1])
  GR3.drawimage(0, 1, 0, 1, 500, 500, GR3::DRAWABLE_GKS)
  GR.updatews
end
GR3.terminate
