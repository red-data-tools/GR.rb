# GR module for Ruby

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE.md)
[![Build Status](https://travis-ci.com/kojix2/ffi-gr.svg?&branch=master)](https://travis-ci.org/kojix2/ffi-gr)

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
gem 'ffi-gr'
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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/GR.rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
