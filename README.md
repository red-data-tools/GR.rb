# GR.rb

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE.txt)
[![Build Status](https://travis-ci.org/red-data-tools/GR.rb.svg?branch=master)](https://travis-ci.org/red-data-tools/GR.rb)
[![Gem Version](https://badge.fury.io/rb/ruby-gr.svg)](https://badge.fury.io/rb/ruby-gr)
[![Gitter Chat](https://badges.gitter.im/red-data-tools/en.svg)](https://gitter.im/red-data-tools/en)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/ruby-gr)

<p align="center">
  <img src="https://user-images.githubusercontent.com/5798442/70857099-13d57600-1f2c-11ea-8f3c-7d81065f13a5.png">
</p>

:bar_chart:  [GR framework](https://github.com/sciapp/gr) - the graphics library for visualisation - for Ruby

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

Have a look in the [`examples`](https://github.com/red-data-tools/GR.rb/tree/master/examples) directory. 

## GR Installation

### Homebrew

```sh
brew install libgr
```

Set environment variable GRDIR.

```sh
export GRDIR="/usr/local/Cellar/libgr/0.44.1"
```

### Mac Linux Windows

Download the [latest release](https://github.com/sciapp/gr/releases).

Set environment variable GRDIR.

```sh
export GRDIR="your/path/to/gr"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/red-data-tools/GR.rb.
