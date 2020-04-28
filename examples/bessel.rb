# frozen_string_literal: true

# https://github.com/ruby-numo/numo-gnuplot-demo/tree/master/gsl/bessel

# Use https://github.com/ruby-numo/numo-gsl
require 'numo/gsl'
require 'gr/plot'

sz = 150
x = Numo::DFloat.new(sz).seq(1) / sz * 30

[
  ['Regular Cylindrical Bessel Functions', :bessel_Jn, 'bessel K', {}],
  ['Irregular Cylindrical Bessel Functions', :bessel_Yn, 'bessel Y', { ylim: [-2, 1] }],
  ['Regular Modified Cylindrical Bessel Functions', :bessel_In, 'bessel I', { xlog: true, ylog: true }],
  ['Irregular Modified Cylindrical Bessel Functions', :bessel_Kn, 'bessel K', { xlog: true, ylog: true }],
  ['Regular Spherical Bessel Functions', :bessel_jl, 'bessel j', {}],
  ['Irregular Spherical Bessel Functions', :bessel_yl, 'bessel y', { ylim: [-2, 1] }],
  ['Regular Modified Spherical Bessel Functions', :bessel_il_scaled, 'bessel i', { xlog: true, ylog: true }],
  ['Irregular Modified Spherical Bessel Functions', :bessel_kl_scaled, 'bessel k', { xlog: true, ylog: true }]
].each do |t, method, labelname, opts|
  y = Array.new(6) { |n| [x, Numo::GSL::Sf.send(method, n, x)] }
  l = Array.new(6) { |n| labelname + n.to_s }
  GR.plot(*y, { title: t, labels: l, xlabel: 'x', ylabel: 'y' }.merge(opts))
  gets
end
