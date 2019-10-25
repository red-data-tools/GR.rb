# frozen_string_literal: true

# https://github.com/jheinen/GR.jl/blob/master/examples/newtons_cradle.jl

require 'gr'
require 'numo/narray'

Theta = 70.0   # initial angle
Gamma = 0.1    # damping coefficient
L = 0.2        # wire length

_w, _h, Ball = GR.readimage(File.expand_path('ball.png', __dir__))

def rk4(x, h, y, f)
  k1 = h * f.call(x, y)
  k2 = h * f.call(x + 0.5 * h, y + 0.5 * k1)
  k3 = h * f.call(x + 0.5 * h, y + 0.5 * k2)
  k4 = h * f.call(x + h, y + k3)
  [x + h, y + (k1 + 2 * (k2 + k3) + k4) / 6.0]
end

def draw_cradle(theta)
  GR.clearws
  GR.setviewport(0, 1, 0, 1)
  GR.setcolorrep(1, 0.7, 0.7, 0.7)
  # draw pivot point
  GR.fillarea([0.3, 0.7, 0.7, 0.3], [0.79, 0.79, 0.81, 0.81])
  # draw balls
  -2.step(2, 1) do |i|
    x = [0.5 + i * 0.06, 0.5 + i * 0.06]
    y = [0.8, 0.4]
    if (theta < 0 && i == -2) || (theta > 0 && i == 2)
      x[1] += Math.sin(theta) * 0.4
      y[1] = 0.8 - Math.cos(theta) * 0.4
    end
    GR.polyline(x, y) # draw wire
    GR.drawimage(x[1] - 0.03, x[1] + 0.03, y[1] - 0.03, y[1] + 0.03, 50, 50, Ball)
  end
  GR.updatews
end

def main
  t = 0.0
  dt = 0.01
  state = Numo::DFloat[Theta * Math::PI / 180, 0]

  start = Time.now
  refresh = start.clone

  deriv = lambda { |_t, state|
    theta, omega = state.to_a
    Numo::DFloat[omega, -Gamma * omega - 9.81 / L * Math.sin(theta)]
  }

  while t < 30
    t, state = rk4(t, dt, state, deriv)
    theta, _omega = state.to_a

    if Time.now - refresh > 0.02 # 20ms
      draw_cradle(theta)
      refresh = Time.now
    end

    now = Time.now - start
    sleep(t - now) if t > now
  end
end

main
