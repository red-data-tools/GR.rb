# GR module for Ruby

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE.md)
[![Build Status](https://travis-ci.com/kojix2/GR.rb.svg?&branch=master)](https://travis-ci.org/kojix2/GR.rb)
[![Gem Version](https://badge.fury.io/rb/ruby-gr.svg)](https://badge.fury.io/rb/ruby-gr)
[![Gitter chat](https://badges.gitter.im/kojix2/GR.rb.svg)](https://gitter.im/kojix2/GR.rb)

[GR framework](https://github.com/sciapp/gr) - the graphics library for visualisation - for Ruby

:construction: Under construction.

## Installation
Install [GR](https://github.com/sciapp/gr/releases).
Set environment variable GRDIR.

```sh
export GRDIR="/your/path/to/gr"
```

Add this line to your application's Gemfile:

```sh
gem 'ruby-gr'
```

## Quick Start

```ruby
require 'gr'

x = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
y = [0.3, 0.5, 0.4, 0.2, 0.6, 0.7]

GR.polyline(x, y)
tick = GR.tick(0, 1)
GR.axes(tick, tick, 0, 0, 1, 1, -0.001)
GR.updatews
```

## Examples
Have a look in the `examples` directory for some simple examples. 

griddata.rb
<p align="center">
  <img src="https://user-images.githubusercontent.com/5798442/68080405-1b3e3580-fe3e-11e9-9f71-592ca2826bcb.png">
</p>

```ruby
require 'gr'
require 'numo/narray'

DFloat = Numo::DFloat

xd = -2 + DFloat.new(100).rand * 4
yd = -2 + DFloat.new(100).rand * 4
zd = xd * Numo::NMath.exp(-xd * xd - yd * yd)

h = -0.5 + DFloat.new(20).seq / 19.0

GR.setviewport(0.1, 0.95, 0.1, 0.95)
GR.setwindow(-2.0, 2.0, -2.0, 2.0)
GR.setspace(-0.5, 0.5, 0, 90)
GR.setmarkersize(1.0)
GR.setmarkertype(-1)
GR.setcharheight(0.024)
GR.settextalign(2, 0)
GR.settextfontprec(3, 0)

x, y, z = GR.gridit(xd, yd, zd, 200, 200)
GR.surface(x, y, z, 5)
GR.contour(x, y, h, z, 0)
GR.polymarker(xd, yd)
GR.axes(0.25, 0.25, -2, -2, 2, 2, 0.01)

GR.updatews
```

clifford_attractor.rb

<p align="center">
  <img src="https://user-images.githubusercontent.com/5798442/68080387-baaef880-fe3d-11e9-9435-f998eaca79da.png">
</p>

```ruby
require 'gr'

include Math

n = 100_000_000
x0 = 0
y0 = 0
a = -1.3
b = -1.3
c = -1.8
d = -1.9
dθ = 0.007

x = [x0]
y = [y0]
θ = 0.007

n.times do |i|
  x <<  (sin(a * y[i]) + c * cos(a * x[i])) * cos(θ)
  y <<  (sin(b * x[i]) + d * cos(b * y[i])) * cos(θ)
  θ += dθ
end

GR.setviewport(0, 1, 0, 1)
GR.setwindow(-3, 3, -3, 3)
GR.setcolormap(8)
GR.shadepoints(x, y, dims: [480, 480], xform: 5)
GR.updatews
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/GR.rb.
