# frozen_string_literal: true

# https://github.com/jheinen/GR.jl/blob/master/examples/double_pendulum3.jl

require 'gr'
require 'gr3'
require 'numo/narray'

include Math
include Numo

G = 9.8 # gravitational constant

def rk4(x, h, y, f)
  k1 = h * f.call(y)
  k2 = h * f.call(y + 0.5 * k1)
  k3 = h * f.call(y + 0.5 * k2)
  k4 = h * f.call(y + k3)
  [x + h, y + (k1 + 2 * (k2 + k3) + k4) / 6.0]
end

def double_pendulum(theta, length, mass)
  direction = DFloat.zeros(3, 2)
  position = DFloat.zeros(3, 3)
  (0..1).each do |i|
    direction[true, i] = [sin(theta[i]) * length[i] * 2,
                          - cos(theta[i]) * length[i] * 2, 0]
    position[true, i + 1] = position[true, i] + direction[true, i]
  end

  # For QtTerms ...
  GR.clearws
  GR.setviewport(0, 1, 0, 1)

  GR3.clear
  # draw pivot point
  GR3.drawcylindermesh(1, [0, 0.2, 0], [0, 1, 0], [0.4, 0.4, 0.4], [0.4], [0.05])
  GR3.drawcylindermesh(1, [0, 0.2, 0], [0, -1, 0], [0.4, 0.4, 0.4], [0.05], [0.2])
  GR3.drawspheremesh(1, [0, 0, 0], [0.4, 0.4, 0.4], [0.05])
  # draw rods
  GR3.drawcylindermesh(2, position.transpose, direction.transpose,
                       [0.6] * 6, [0.05, 0.05], length.map { |i| i * 2 })
  # draw bobs
  GR3.drawspheremesh(2, position[true, 1..2].transpose, [1] * 6, mass.map { |i| i * 0.2 })

  GR3.drawimage(0, 1, 0, 1, 500, 500, GR3::DRAWABLE_GKS)
  GR.updatews
end

def main
  l1 = 1.2       # length of rods
  l2 = 1.0
  m1 = 1.0       # weights of bobs
  m2 = 1.5
  t1 = 100.0     # inintial angles
  t2 = -20.0

  derivs = lambda { |state|
    # The following derivation is from:
    # http://scienceworld.wolfram.com/physics/DoublePendulum.html
    t1, w1, t2, w2 = state.to_a
    a = (m1 + m2) * l1
    b = m2 * l2 * cos(t1 - t2)
    c = m2 * l1 * cos(t1 - t2)
    d = m2 * l2
    e = -m2 * l2 * w2**2 * sin(t1 - t2) - G * (m1 + m2) * sin(t1)
    f =  m2 * l1 * w1**2 * sin(t1 - t2) - m2 * G * sin(t2)
    DFloat[w1, (e * d - b * f) / (a * d - c * b), w2, (a * f - c * e) / (a * d - c * b)]
  }

  w1 = 0.0
  w2 = 0.0
  t = 1
  dt = 0.04
  state = DFloat[t1, w1, t2, w2] * PI / 180

  GR3.setcameraprojectionparameters(45, 1, 100)
  GR3.cameralookat(6, -2, 4, 0, -2, 0, 0, 1, 0)
  GR3.setbackgroundcolor(1, 1, 1, 1)
  GR3.setlightdirection(1, 1, 10)

  start = Time.now

  while t < 30
    t, state = rk4(t, dt, state, derivs)
    t1, w1, t2, w2 = state.to_a
    double_pendulum([t1, t2], [l1, l2], [m1, m2])

    now = (Time.now - start)
    sleep(t - now) if t > now
  end
end

main
