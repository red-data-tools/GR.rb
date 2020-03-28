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

## Examples

Have a look in the [`examples`](https://github.com/red-data-tools/GR.rb/tree/master/examples) directory. Start with [`fast_plot`](https://github.com/red-data-tools/GR.rb/blob/master/examples/fast_plots.rb).

## Features

#### GR::Plot

A simple, matlab-style API.

```ruby
require 'gr/plot'
```

`plot` `step` `scatter` `stem` `histogram` `contour` `contourf` `hexbin` `heatmap` `wireframe` `surface` `plot3` `scatter3` `imshow` `isosurface` `polar` `polarhist` `polarheatmap` `trisurf` `tricont` `shade` `volume`

#### GR

```ruby
require 'gr'
```

#### GR3

```ruby
require 'gr3'
```

## Documentation

- [GR Framework](https://gr-framework.org/)
- [GR.rb API Documentation](https://rubydoc.info/gems/ruby-gr)

## GR Installation

### Official binary release

Download the [latest release](https://github.com/sciapp/gr/releases).

Set environment variable GRDIR.

```sh
export GRDIR="your/path/to/gr"
```

### Homebrew

```sh
brew install libgr
```

Set environment variable GRDIR.

```sh
export GRDIR=$(brew --prefix libgr)
```

If you fail to build libgr using homebrew, Please feel free to [send us your feedback](https://github.com/red-data-tools/GR.rb/issues).

## Backend for Charty

GR.rb is expected to be the backend for [Charty](https://github.com/red-data-tools/charty) in the future.

## Contributing

* Report bugs
* Fix bugs and submit pull requests
* Write, clarify, or fix documentation
* Suggest or add new features
