# frozen_string_literal: true

# https://ja.stackoverflow.com/questions/63624/
# by metropolis
# http://slpr.sakura.ne.jp/qp/code-riemann-zeta/
# by (c)sikino

require 'cmath'
require 'gr/plot'
ENV['GKS_WSTYPE'] = 'gksqt'

PI       = Math::PI
Q        = [
  0.99999999999980993, 676.5203681218851, -1259.1392167224028,
  771.32342877765313, -176.61502916214059, 12.507343278686905,
  -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7
].freeze
QLEN     = Q.count
QLEN_G   = QLEN - 2
SQRT_2PI = Math.sqrt(2.0 * PI)
EPSILON  = 1.0e-16

# Gamma function - Rosetta Code
# https://rosettacode.org/wiki/Gamma_function#C.23
def cgamma(z)
  if z.real < 0.5
    PI / (CMath.sin(PI * z) * cgamma(1.0 - z))
  else
    z -= 1.0
    x = (1...QLEN).inject(Q[0]) { |s, i| s + Q[i] / (z + i) }
    t = z + QLEN_G + 0.5
    SQRT_2PI * (t**(z + 0.5)) * CMath.exp(-t) * x
  end
end

def _zeta(z)
  n = 2
  prev = Complex(1)
  sum = Complex(1)
  while n < 1e+6
    add = 1.0 / (n**z)
    sum += add
    break if (add - prev).abs2 < EPSILON

    n += 1
    prev = add
  end
  sum
end

def zeta_p_series(z)
  if z.real > 1.0
    _zeta(z)
  else
    (2.0**z) * (PI**(z - 1.0)) *
      CMath.sin(PI * z / 2.0) * cgamma(1.0 - z) * _zeta(1.0 - z)
  end
end

# Riemann zeta function - binomial factor
def combinations(n, k)
  return 1 if (k == 0) || (k == n)

  (k + 1..n).reduce(:*) / (1..n - k).reduce(:*)
end

def zeta_binomial(z)
  n = 1
  prev = Complex(0)
  sum = Complex(0)
  loop do
    add = (1..n).inject(Complex(n)) do |s, k|
      s + combinations(n, k) * ((-1)**k) / ((k + 1.0)**z)
    end / (2**(n + 1))
    sum += add
    break if (add - prev).abs2 < EPSILON

    n += 1
    prev = add
  end
  sum / (1.0 - (2**(1.0 - z)))
end

# Riemann zeta function
def zeta(z)
  case z
  when Complex(1.0)
    Float::NAN
  when Complex(0.0)
    Complex(0.5)
  when Complex(-1.0)
    Complex(-1.0 / 12.0)
  else
    if (z.real > -1.0) && (z.imag.abs < 40.0)
      zeta_binomial(z)
    else
      zeta_p_series(z)
    end
  end
end

# ζ(z): Re(z)[-15.0,  5.0], Im(z)[-20.0, 20.0]

xs = []
ys = []
zs = []

-15.step(5, 0.1) do |r|
  -20.step(20, 0.1) do |i|
    z = zeta(Complex(r, i))
    puts format("%.1f\t%.1f\t%e\t%e\t%e\n", r, i, z.real, z.imag, z.abs)
    next if z.real.nan?

    xs << r
    ys << i
    zs << z
  end
end

[
  [:real, 'Re\(\zeta\(s\)\)'],
  [:imag, 'Im\(\zeta\(s\)\)'],
  [:abs, '|\zeta\(s\)|']
].each do |part, zlabel|
  %i[contour contourf wireframe surface].each do |type|
    print "[#{part}] Now creating #{type} plot. Please wait..."
    time = Time.now
    GR.send(type, xs, ys, zs.map { |z| z.send(part).clamp(0, 2) },
            { title: "Riemann zeta function - #{type}",
              figsize: [8, 6],
              rotation: 45,
              tilt: 78,
              xlabel: 'Re\(s\)',
              ylabel: 'Im\(s\)',
              zlabel: zlabel,
              accelerate: false })
    puts "done. time: #{(Time.now - time).round(2)} s"
    # gets
  end
end
puts 'Press Enter to exit...'
gets
