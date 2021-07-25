# GR.rb

[![Gem Version](https://img.shields.io/gem/v/ruby-gr?color=brightgreen)](https://rubygems.org/gems/ruby-gr)
[![CI](https://github.com/red-data-tools/GR.rb/workflows/CI/badge.svg)](https://github.com/red-data-tools/GR.rb/actions)
[![Gitter Chat](https://badges.gitter.im/red-data-tools/en.svg)](https://gitter.im/red-data-tools/en)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/ruby-gr)

[![rdatasets-1](https://i.imgur.com/XEQ6wKs.png)](examples/rdatasets.rb)
[![stem](https://i.imgur.com/3w0Ejrm.png)](examples/fast_plots.rb)
[![histogram](https://i.imgur.com/xUdoA2s.png)](examples/fast_plots.rb)
[![barplot](https://i.imgur.com/52bOFKE.png)](examples/fast_plots.rb)
[![scatter3](https://i.imgur.com/yTTVetQ.png)](examples/fast_plots.rb)
[![volume](https://i.imgur.com/CuRN6oC.png)](examples/fast_plots.rb)
[![griddata](https://i.imgur.com/58HdYDo.png)](examples/griddata.rb)
[![2darray](https://i.imgur.com/aKR2FJG.png)](examples/2darray.rb)
[![2dpolararray](https://i.imgur.com/cmSrxvS.png)](examples/2dpolararray.rb)
[![hexbin](https://i.imgur.com/unWhQHr.png)](examples/hexbin.rb)
[![rdatasets-2](https://i.imgur.com/ZPit2F5.png)](examples/rdatasets.rb)
[![rdatasets-3](https://i.imgur.com/TbNoxwy.png)](examples/rdatasets.rb)
[![surface](https://i.imgur.com/sWdaHme.png)](examples/kws2.rb)
[![face](https://i.imgur.com/uLCKi2r.png)](examples/face.rb)
[![shade](https://i.imgur.com/VJmS3EQ.png)](examples/shade_ex.rb)

:bar_chart:  [GR framework](https://github.com/sciapp/gr) - powerful visualization library - for Ruby

## Installation

GR.rb supports Ruby 2.5+.

First, [install GR](#gr-installation). Then install `ruby-gr` gem.

```sh
gem install ruby-gr
```
Note: If you are using [RubyInstaller](https://rubyinstaller.org/) (Windows), pacman will automatically install [mingw-w64-gr](https://packages.msys2.org/base/mingw-w64-gr).

Set environment variable `GRDIR`.

```sh
export GRDIR="/your/path/to/gr"
```

If you use package managers to install GR, [pkg-config](https://github.com/ruby-gnome/pkg-config) may automatically detect the shared library location without specifying the `GRDIR` environment variable.

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

Save the figure in PNG format.

```ruby
GR.savefig("figure.png")
```

## API Overview

There are two different approaches when plotting with GR.rb. One is to call Matlab-like APIs. The other is to call GR/GR3 native functions.

#### GR::Plot - A simple, matlab-style API.

```ruby
require 'gr/plot'
GR.plot(x, y)
```

Below are a list of available functions. See [GR.rb Wiki](https://github.com/red-data-tools/GR.rb/wiki) for details.
Some GR module methods are overwritten.

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

2-D Plots and common 3-D Plots.

```ruby
require 'gr'

# For example
GR.setviewport(0.1, 0.9, 0.1, 0.9)
GR.setwindow(0.0, 20.0, 0.0, 20.0)
```

#### GR3 - A module for calling native GR3 functions.

Complex 3D scenes.

```ruby
require 'gr3'

# For example
GR3.cameralookat(-3, 2, -2, 0, 0, 0, 0, 0, -1)
```

### Using GR.rb non-interactively

Both APIs will by default start a Qt based window to show the result of the last call.
This behavior is caused by GR itself as it will [implicitly generate output to a file or application](https://gr-framework.org/workstations.html#no-output).
If you want to use GR.rb non-interactively, eg., as part of a static site build, you can do this by setting the environment variable `GKS_WSTYPE`to `100`.

```sh
export GKS_WSTYPE=100
```

## Documentation

- [GR.rb Wiki](https://github.com/red-data-tools/GR.rb/wiki)
- [GR Framework](https://gr-framework.org/)
- [GR.rb API Documentation](https://rubydoc.info/gems/ruby-gr)

Although GR.rb adds methods dynamically, we try our best to provide a complete yard document. If you want to see more up-to-date information, we recommend using the official GR reference.

## GR Installation

### Installing an official release (recommended)

Download the [latest release](https://github.com/sciapp/gr/releases).

Set environment variable GRDIR.

```sh
export GRDIR="your/path/to/gr"
```

macOS : Please  the section "How to open apps from un-notarized or unidentified developers" in the Apple documentation ["Safely open apps on your Mac"](https://support.apple.com/en-us/HT202491).

### Using package managers

* The third party GR packages for Mac, Linux and Windows are available (for advanced users).
* If you find any problem, please report the issue [here](https://github.com/red-data-tools/GR.rb/issues).
* Note: These packages may not have some features such as video output.

#### Mac - Homebrew

```sh
brew install libgr
export GKS_WSTYPE=411 # gksqt (recommended)
```

#### Linux - APT

[packages.red-data-tools.org](https://github.com/red-data-tools/packages.red-data-tools.org) provides `libgr-dev`, `libgr3-dev` and `libgrm-dev`

Debian GNU/Linux and Ubuntu 

```sh
sudo apt install -y -V ca-certificates lsb-release wget
wget https://packages.red-data-tools.org/$(lsb_release --id --short | tr 'A-Z' 'a-z'\
  )/red-data-tools-apt-source-latest-$(lsb_release --codename --short).deb
sudo apt install -y -V ./red-data-tools-apt-source-latest-$(lsb_release --codename --short).deb
sudo apt update
sudo apt install libgrm-dev
```

#### Linux - Yum

CentOS

```sh
(. /etc/os-release && sudo dnf install -y https://packages.red-data-tools.org/centos/${VERSION_ID}/red-data-tools-release-latest.noarch.rpm)
sudo dnf install -y gr-devel
```

#### Windows - MSYS2

If you are using Rubyinstaller, pacman will automatically install [mingw-w64-gr](https://packages.msys2.org/base/mingw-w64-gr) when the gem is installed.

## Contributing

GR.rb is a library under development, so even small improvements like fixing typos are welcome!
Please feel free to send us your PR.

* [Report bugs](https://github.com/red-data-tools/GR.rb/issues)
* Fix bugs and [submit pull requests](https://github.com/red-data-tools/GR.rb/pulls)
* Write, clarify, or fix documentation
* Suggest or add new features
* Update GR packages ( Homebrew, MinGW, red-data-tools )
* Create visualization tools based on GR.rb

To get started with development:

```sh
git clone https://github.com/red-data-tools/GR.rb
cd GR.rb
bundle install
bundle exec rake test
```

* [I'm new to Ruby](https://github.com/red-data-tools/GR.rb/wiki/I%27m-new-to-Ruby)

## Future plans

* GR.rb will be the default backend for [Charty](https://github.com/red-data-tools/charty).
* [Object-oriented interface](https://github.com/kojix2/GRUtils.rb) based on [GRUtils.jl](https://github.com/heliosdrm/GRUtils.jl). 

## Acknowledgements

We would like to thank Josef Heinen, the creator of [GR](https://github.com/sciapp/gr) and [GR.jl](https://github.com/jheinen/GR.jl), Florian Rhiem, the creator of [python-gr](https://github.com/sciapp/python-gr), and all [GR](https://github.com/sciapp/gr) developers.
