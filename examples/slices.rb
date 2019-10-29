# frozen_string_literal: true

# https://github.com/jheinen/GR.jl/blob/master/examples/slices.jl

require 'gr'
require 'gr3'
require 'numo/narray'

data = Numo::UInt16.from_string(File.binread(File.expand_path('mri.raw', __dir__)))
                   .reshape(64, 64, 93)
data[data > 2000] = 2000
data = Numo::UInt16.cast((data / 2000.0 * Numo::UInt16::MAX).floor)
data = data.transpose(2, 1, 0)

def draw(mesh, x: nil, y: nil, z: nil, d: nil)
  GR3.clear
  GR3.drawmesh(mesh, 1, [0, 0, 0], [0, 0, 1], [0, 1, 0], [1, 1, 1], [1, 1, 1])
  GR3.drawslicemeshes(d, x, y, z)
  GR.clearws
  GR3.drawimage(0, 1, 0, 1, 500, 500, GR3::DRAWABLE_GKS)
  GR.updatews
end

GR.setviewport(0, 1, 0, 1)
GR3.cameralookat(-3, 2, -2, 0, 0, 0, 0, 0, -1)

mesh = GR3.createisosurfacemesh(data, [2.0 / 63, 2.0 / 63, 2.0 / 92], [-1.0, -1.0, -1.0], 40_000)

GR.setcolormap(1)

0.step(1, 0.005) do |z|
  draw(mesh, x: 0.9, z: z, d: data)
end

1.step(0.5, -0.0025) do |y|
  draw(mesh, x: 0.9, y: y, z: 1, d: data)
end

GR.setcolormap(19)

0.9.step(0, -0.003) do |x|
  draw(mesh, x: x, y: 0.5, z: 1, d: data)
end

0.step(0.9, 0.003) do |x|
  draw(mesh, x: x, z: 1, d: data)
end

GR3.terminate
