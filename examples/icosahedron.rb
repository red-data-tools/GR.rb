# frozen_string_literal: true

ENV['GKS_DOUBLE_BUF'] = '1'

require 'gr'

N = (ARGV[0] || 2).to_i

x = [0, 0.850651, 0.850651, -0.850651, -0.850651, -0.525731, 0.525731, 0.525731, -0.525731, 0, 0, 0]
y = [-0.525731, 0, 0, 0, 0, 0.850651, 0.850651, -0.850651, -0.850651, -0.525731, 0.525731, 0.525731]
z = [0.850651, 0.525731, -0.525731, -0.525731, 0.525731, 0, 0, 0, 0, -0.850651, -0.850651, 0.850651]

connections = [
  [3, 3, 7, 2],
  [3, 8, 3, 2],
  [3, 5, 6, 4],
  [3, 4, 9, 5],
  [3, 6, 12, 7],
  [3, 7, 11, 6],
  [3, 11, 3, 10],
  [3, 10, 4, 11],
  [3, 9, 10, 8],
  [3, 8, 1, 9],
  [3, 1, 2, 12],
  [3, 12, 5, 1],
  [3, 3, 11, 7],
  [3, 7, 12, 2],
  [3, 6, 11, 4],
  [3, 5, 12, 6],
  [3, 8, 10, 3],
  [3, 2, 1, 8],
  [3, 10, 9, 4],
  [3, 9, 1, 5]
]

# use GR's distinct colors
colors = Array.new(connections.size) { |i| GR.inqcolor(980 + i) | 0xdf000000 }

GR.setviewport(0, 1, 0, 1)
GR.setwindow(-1, 1, -1, 1)
GR.setwindow3d(-1, 1, -1, 1, -1, 1)

N.times do
  360.times do |angle|
    GR.clearws
    GR.setspace3d(30 + angle, 80, 0, 0)

    GR.polygonmesh3d(x, y, z, connections.flatten, colors)

    GR.updatews
    sleep(0.01)
  end
end
