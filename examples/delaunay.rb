# frozen_string_literal: true

# https://github.com/jheinen/GR.jl/blob/master/examples/delaunay.jl

require 'gr/plot'

def points_from_image(img, npts)
  h, w = img.shape
  xpts = []
  ypts = []
  cols = []
  npts.times do
    x = rand * w
    y = rand * h
    c = img[y.floor, x.floor]
    r = (c & 0xff) / 255.0
    g = ((c >> 8)  & 0xff) / 255.0
    b = ((c >> 16) & 0xff) / 255.0
    gray = 0.2989 * r + 0.5870 * g + 0.1140 * b
    next if rand > Math.sqrt(1 - gray)

    xpts << x
    ypts << y
    cols << GR.inqcolorfromrgb(r, g, b)
  end
  [xpts, ypts, cols].map { |ar| Numo::DFloat.cast(ar) }
end

w, h, data = GR.readimage(File.expand_path('ruby-logo.png', __dir__))
img = Numo::UInt32.cast(data).reshape(h, w)

x, y, cols = points_from_image(img, 100_000)
cols = cols.cast_to(Numo::Int32)

GR.settransparency(0.5)
GR.setmarkersize(0.5)
GR.scatter(x.minmax, y.minmax, figsize: [4, 5], yflip: true) # FIXME

n, tri = GR.delaunay(x, y)
tri = Numo::Int32.cast(tri)
n.times do |i|
  if (cols[tri[i, true]].ne 1).all?
    GR.settransparency(0.5)
    GR.setfillcolorind(cols[tri[i, 0]])
  else
    GR.settransparency(0.1)
    GR.setfillcolorind(1)
  end
  GR.fillarea(x[tri[i, true]], y[tri[i, true]])
  GR.updatews if i % 2500 == 0
end
GR.updatews
gets
