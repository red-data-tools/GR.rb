# GR.rb

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE.txt)
[![Build Status](https://travis-ci.org/red-data-tools/GR.rb.svg?branch=master)](https://travis-ci.org/red-data-tools/GR.rb)
[![Gem Version](https://badge.fury.io/rb/ruby-gr.svg)](https://badge.fury.io/rb/ruby-gr)
[![Gitter Chat](https://badges.gitter.im/red-data-tools/en.svg)](https://gitter.im/red-data-tools/en)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/ruby-gr)

![rdatasets-1](https://i.imgur.com/XEQ6wKs.png)
![stem](https://i.imgur.com/3w0Ejrm.png)
![histogram](https://i.imgur.com/xUdoA2s.png)
![barplot](https://i.imgur.com/52bOFKE.png)
![scatter3](https://i.imgur.com/yTTVetQ.png)
![volume](https://i.imgur.com/CuRN6oC.png)
![griddata](https://i.imgur.com/58HdYDo.png)
![2darray](https://i.imgur.com/aKR2FJG.png)
![2dpolararray](https://i.imgur.com/cmSrxvS.png)
![hexbin](https://i.imgur.com/unWhQHr.png)
![rdatasets-2](https://i.imgur.com/ZPit2F5.png)
![rdatasets-3](https://i.imgur.com/TbNoxwy.png)
![surface](https://i.imgur.com/sWdaHme.png)
![face](https://i.imgur.com/uLCKi2r.png)
![shade](https://i.imgur.com/VJmS3EQ.png)

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

## API Overview

There are two different approaches to plotting with GR.rb. One way is to call Matlab-like APIs. The other is to call GR/GR3 native functions. We are planning to prepare a more object-oriented interface based on [GRUtils.jl](https://github.com/heliosdrm/GRUtils.jl) in the future.

#### GR::Plot - A simple, matlab-style API. 

```ruby
require 'gr/plot'
GR.plot(x, y)
```

List of vailable functions. See [GR.rb Wiki](https://github.com/red-data-tools/GR.rb/wiki) for details.

[`plot`](../../wiki/Plotting-functions#plot)
[`step`](../../wiki/Plotting-functions#step)
[`plot3`](../../wiki/Plotting-functions#plot3)
[`polar`](../../wiki/Plotting-functions#polar)
[`scatter`](../../wiki/Plotting-functions#scatter)
[`scatter3`](../../wiki/Plotting-functions#scatter3)
[`stem`](../../wiki/Plotting-functions#stem)
[`barplot`](../../wiki/Plotting-functions#barplot)
[`histogram`](../../wiki/Plotting-functions#histogram)
[`polarhistogram`](../../wiki/Plotting-functions#polarhistogram)
[`hexbin`](../../wiki/Plotting-functions#hexbin)
[`contour`](../../wiki/Plotting-functions#contour)
[`contourf`](../../wiki/Plotting-functions#contourf)
[`tricont`](../../wiki/Plotting-functions#tricont)
[`surface`](../../wiki/Plotting-functions#surface)
[`trisurf`](../../wiki/Plotting-functions#trisurf)
[`wireframe`](../../wiki/Plotting-functions#wireframe)
[`volume`](../../wiki/Plotting-functions#volume)
[`heatmap`](../../wiki/Plotting-functions#heatmap)
[`polarheatmap`](../../wiki/Plotting-functions#polarheatmap)
[`shade`](../../wiki/Plotting-functions#shade)
[`imshow`](../../wiki/Plotting-functions#imshow)
[`isosurface`](../../wiki/Plotting-functions#isosurface)

#### GR - A module for calling native GR functions.

```ruby
require 'gr'

# For example
GR.setviewport(0.1, 0.9, 0.1, 0.9)
GR.setwindow(0.0, 20.0, 0.0, 20.0)
```

#### GR3 - A module for calling native GR3 functions.

```ruby
require 'gr3'

# For example
GR3.cameralookat(-3, 2, -2, 0, 0, 0, 0, 0, -1)
```

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

* The third party GR packages for Mac, Linux and Windows are available (for advanced users).
* If you find any problem, please report the issue [here](https://github.com/red-data-tools/GR.rb/issues).

#### Mac - Homebrew

```sh
brew install libgr
```

Set environment variable GRDIR.

```sh
export GRDIR=$(brew --prefix libgr)
```

#### Linux - APT Yum

[packages.red-data-tools.org](https://github.com/red-data-tools/packages.red-data-tools.org) provides `libgr-dev` and `libgr3-dev`.

#### Windows - MSYS2

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

