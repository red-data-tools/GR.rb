# frozen_string_literal: true

require 'gr/plot'
require 'numo/narray'

x = Numo::DComplex.new(314).seq / 100
w = x * Numo::NMath.exp(-2 * x * 1i)

GR.plot(w.real, w.imag, nil, x.abs, linewidth: 10,
                                    title: "\$f(x) = xe^{-2xi} \\forall x \\in [0,\\pi]\$",
                                    xlabel: "\$\\Re e\\{f(x)\\}\$",
                                    ylabel: "\$\\Im e\\{f(x)\\}\$")

gets
