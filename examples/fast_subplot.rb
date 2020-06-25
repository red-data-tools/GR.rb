# frozen_string_literal: true

require 'gr/plot'
DFloat = Numo::DFloat
NMath = Numo::NMath

%i[barplot stem step plot].each_with_index do |t, i|
  h = GR.subplot(2, 2, i + 1)
  GR.send t, [*1..10], [*1..10].shuffle, h.merge(title: "subplot #{i}")
end
sleep 1.5

# https://heliosdrm.github.io/GRUtils.jl/latest/#A-basic-example-1

x = DFloat.linspace(0, 10, 500)
y = NMath.sin(x**2) * NMath.exp(-x)
GR.plot(x, y, ylim: [-0.5, 0.5],
              xlabel: 'X', ylabel: 'Y', title: 'Example plot')
k = GR.hold
GR.plot([x, -2 * NMath.exp(x)**-1, '--k'], [x, 2 * NMath.exp(x)**-1, '--k'], k)
sleep 1.5

ax = DFloat.new(20_000).rand_norm
ay = DFloat.new(20_000).rand_norm
bx = DFloat.new(20_000).rand_norm(3)
by = DFloat.new(20_000).rand_norm(3)
cx = DFloat.new(20_000).rand_norm(3)
cy = DFloat.new(20_000).rand_norm(-3)

x = DFloat.hstack [ax, bx, cx]
y = DFloat.hstack [ay, by, cy]

GR.shade x, y, subplot: [0.02, 0.2, 0.8, 0.98], clear: true, update: false
GR.histogram x, subplot: [0.135, 0.89, 0.8, 0.98], clear: false, nbins: 50, update: false
GR.histogram y, subplot: [0.02, 0.2, 0.0, 0.82], horizontal: true, xflip: true, nbins: 50, grid: false, clear: false, update: false
GR.hexbin x, y, subplot: [0.12, 1.0, 0.0, 0.82], clear: false, update: true
sleep 1.5
