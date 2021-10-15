require 'gr'

x = [0, 1, 0, 1, 0.707]
y = [0, 0, 1, 1, 0.707]
z = [0, 0, 0, 0, 0.707]

connections = [
  [4, 1, 2, 4, 3],  # 1 quadrilateral
  [3, 1, 2, 5],     # 4 triangles
  [3, 2, 4, 5],
  [3, 4, 3, 5],
  [3, 3, 1, 5]
]
# AABBGGRR
colors = [0xdf753e80, 0xdf0068ff, 0xdfc0a35a, 0xdf2000c1, 0xdf62a2ce]

GR.setviewport(0, 1, 0, 1)
GR.setwindow(-1, 1, -1, 1)
GR.setwindow3d(0, 1, 0, 1, 0, 1)
GR.setspace3d(30, 80, 0, 0)

GR.polygonmesh3d(x, y, z, connections.flatten, colors)

GR.updatews

gets