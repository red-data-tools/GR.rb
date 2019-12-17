
# https://github.com/ruby-numo/numo-gnuplot-demo/tree/master/gsl/bessel

require 'numo/gsl'
require 'gr/plot'

sz = 150
x = Numo::DFloat.new(sz).seq(1)/sz*30
y = 5.times.map{|n| [x,Numo::GSL::Sf.bessel_Jn(n,x)]}

GR.plot(*y, labels: [*0..4].map(&:to_s))
gets