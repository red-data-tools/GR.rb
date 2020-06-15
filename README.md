# GR.rb

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE.txt)
[![Build Status](https://travis-ci.org/red-data-tools/GR.rb.svg?branch=master)](https://travis-ci.org/red-data-tools/GR.rb)
[![Gem Version](https://badge.fury.io/rb/ruby-gr.svg)](https://badge.fury.io/rb/ruby-gr)
[![Gitter Chat](https://badges.gitter.im/red-data-tools/en.svg)](https://gitter.im/red-data-tools/en)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/ruby-gr)

<p align="center">
  <img src="https://user-images.githubusercontent.com/5798442/70857099-13d57600-1f2c-11ea-8f3c-7d81065f13a5.png">
</p>

:bar_chart:  [GR framework](https://github.com/sciapp/gr) - the graphics library for visualization - for Ruby

## Installation

GR.rb supports Ruby 2.4+.

[Install GR](#gr-installation).

Set environment variable GRDIR, if you have not already done. 

```sh
export GRDIR="/your/path/to/gr"
```

Add this line to your application's Gemfile:

```sh
gem 'ruby-gr'
```

GR3 and GR::Plot require [numo-narray](https://github.com/ruby-numo/numo-narray).

## Quick Start

<p align="center">
  <img src="https://user-images.githubusercontent.com/5798442/69689128-74cb1480-110b-11ea-9097-29e878a19e8f.png">
</p>

```ruby
require 'gr/plot'

x = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
y = [0.3, 0.5, 0.4, 0.2, 0.6, 0.7]

GR.plot(x, y)
```

<p align="center">
  <img src="https://user-images.githubusercontent.com/5798442/84570709-242ab880-adca-11ea-9099-3a6b3418bf19.png">
</p>

```ruby
require 'gr/plot'

x  = Numo::DFloat.linspace(0, 10, 101)
y1 = Numo::NMath.sin(x)
y2 = Numo::NMath.cos(x)

GR.plot(
  [x, y1, 'bo'], [x, y2, 'g*'],
  title:    "Multiple plot example",
  xlabel:   "x",
  ylabel:   "y",
  ylim:     [-1.2, 1.2],
  labels:   ["sin(x)", "cos(x)"],
  location: 11
)
```

Save to PNG file.

```ruby
GR.savefig("figure.png")
```

## Features

There are two layers to the GR.rb API. 
* High-level API - GR::Plot
* Low-level API - GR, GR3

#### GR::Plot

A simple, matlab-style API. 

```ruby
require 'gr/plot'
GR.plot(x, y)
```

List of vailable functions. See [GR.rb Wiki](https://github.com/red-data-tools/GR.rb/wiki) for details.

[`plot`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#plot)
[`step`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#step)
[`plot3`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#plot3)
[`polar`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#polar)
[`scatter`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#scatter)
[`scatter3`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#scatter3)
[`stem`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#stem)
[`barplot`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#barplot)
[`histogram`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#histogram)
[`polarhistogram`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#polarhistogram)
[`hexbin`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#hexbin)
[`contour`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#contour)
[`contourf`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#contourf)
[`tricont`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#tricont)
[`surface`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#surface)
[`trisurf`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#trisurf)
[`wireframe`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#wireframe)
[`volume`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#volume)
[`heatmap`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#heatmap)
[`polarheatmap`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#polarheatmap)
[`shade`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#shade)
[`imshow`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#imshow)
[`isosurface`](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions#isosurface)

#### GR module

you can call native GR functions.

```ruby
require 'gr'

# For example
GR.setviewport(0.1, 0.9, 0.1, 0.9)
GR.setwindow(0.0, 20.0, 0.0, 20.0)
```

#### GR3 module

You can call native GR3 functions.

```ruby
require 'gr3'

# For example
GR3.cameralookat(-3, 2, -2, 0, 0, 0, 0, 0, -1)
```

* GR.rb can be used in Jupyter Notebook.

## Documentation

- [GR.rb Wiki](https://github.com/red-data-tools/GR.rb/wiki)
- [GR Framework](https://gr-framework.org/)
- [GR.rb API Documentation](https://rubydoc.info/gems/ruby-gr)

## GR Installation

### Installing an official release (recommended)

Download the [latest release](https://github.com/sciapp/gr/releases).

Set environment variable GRDIR.

```sh
export GRDIR="your/path/to/gr"
```

* macOS Catalina and macOS Mojave: See the "How to open an app that hasn’t been notarized or is from an unidentified developer" section of [Safely open apps on your Mac](https://support.apple.com/en-us/HT202491) in the Apple documentation.

### Using your package manager

We provide third party GR packages for Mac, Linux and Windows (for advanced users).
If you find any problems, please report them to the [issue](https://github.com/red-data-tools/GR.rb/issues).

#### Mac: Homebrew

```sh
brew install libgr
```

Set environment variable GRDIR.

```sh
export GRDIR=$(brew --prefix libgr)
```

#### Linux: APT Yum

[packages.red-data-tools.org](https://github.com/red-data-tools/packages.red-data-tools.org) provides `libgr-dev` and `libgr3-dev`.

#### Windows: MSYS2

If you are using Rubyinstaller, pacman will automatically install [mingw-w64-gr](https://packages.msys2.org/base/mingw-w64-gr) when the gem is installed.

## Backend for Charty

GR.rb will be the default backend for [Charty](https://github.com/red-data-tools/charty).

## Contributing

* Report bugs
* Fix bugs and submit pull requests
* Write, clarify, or fix documentation
* Suggest or add new features
* Create visualization library based on GR.rb

## Acknowledgements

We would like to thank Josef Heinen, the creator of [GR.jl](https://github.com/jheinen/GR.jl), Florian Rhiem, the creator of  [python-gr](https://github.com/sciapp/python-gr), and [GR](https://github.com/sciapp/gr) developers.

