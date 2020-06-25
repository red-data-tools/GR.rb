# frozen_string_literal: true

require 'gr/plot'
DFloat = Numo::DFloat
NMath = Numo::NMath

%i[barplot stem step plot].each_with_index do |t, i|
  h = GR.subplot(2, 2, i + 1)
  GR.send t, [*1..10], [*1..10].shuffle, h.merge(title: "subplot #{i}")
end
gets

# https://heliosdrm.github.io/GRUtils.jl/latest/#A-basic-example-1

x = DFloat.linspace(0, 10, 500)
y = NMath.sin(x**2) * NMath.exp(-x)
GR.plot(x, y, ylim: [-0.5, 0.5],
              xlabel: 'X', ylabel: 'Y', title: 'Example plot')
k = GR.hold
GR.plot([x, -2 * NMath.exp(x)**-1, '--k'], [x, 2 * NMath.exp(x)**-1, '--k'], k)
gets
