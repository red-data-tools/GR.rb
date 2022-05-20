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

First, [install GR](#gr-installation). Then install [`gr-plot`](https://github.com/red-data-tools/gr-plot) gem.

```sh
gem install gr-plot
```

[pkg-config](https://github.com/ruby-gnome/pkg-config) will detect the location of the shared library. Otherwise, you need to specify the environment variable. 

```sh
export GRDIR="/your/path/to/gr"
```

## Quick Start

:point_right: [Wiki -plotting functions](https://github.com/red-data-tools/GR.rb/wiki/Plotting-functions)

<p align="center">
  <img src="https://user-images.githubusercontent.com/5798442/69689128-74cb1480-110b-11ea-9097-29e878a19e8f.png">
</p>

```ruby
require 'gr/plot'

x = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
y = [0.3, 0.5, 0.4, 0.2, 0.6, 0.7]

# show the figure
GR.plot(x, y)

# Save the figure in PNG format.
GR.savefig("figure.png")
```

GR.rb supports [Jupyter Notebook / Lab](../../wiki/Jupyter-Notebook).

## API Overview

#### [GR::Plot - A simple, matlab-style API](https://github.com/red-data-tools/gr-plot)

```ruby
require 'gr/plot'
GR.plot(x, y)
```

List of available functions. 

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

See [GR.rb Wiki](https://github.com/red-data-tools/GR.rb/wiki) for details.
Some GR module methods are overwritten. Code has been moved to [gr-plot](https://github.com/red-data-tools/gr-plot).

#### GR - A module for calling native GR functions

2-D Plots and common 3-D Plots.

```ruby
require 'gr'

# For example
GR.setviewport(0.1, 0.9, 0.1, 0.9)
GR.setwindow(0.0, 20.0, 0.0, 20.0)
```

#### GR3 - A module for calling native GR3 functions

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
- [GR.rb API Documentation](https://rubydoc.info/gems/ruby-gr) - Yard documents.
- [GR Framework](https://gr-framework.org/) - The official GR reference.

## GR Installation

### Installing an official release (recommended)

Download the [latest release](https://github.com/sciapp/gr/releases) and place it where you want. Then set environment variable `GRDIR`.

```sh
export GRDIR="your/path/to/gr"
```

macOS : See ["How to open apps from un-notarized or unidentified developers"](https://support.apple.com/en-us/HT202491) in the Apple documentation.

### Using package managers

The third party GR packages for Mac, Linux and Windows are available for advanced users. However, these packages are provided by OSS volunteers and may not be the latest version or support some features (such as video output). If you find any problem, please report the issue [here](https://github.com/red-data-tools/GR.rb/issues). 

#### Mac - Homebrew

```sh
brew install libgr
export GKS_WSTYPE=411 # Set the workstation type to gksqt (recommended)
```

#### Linux - openSUSE Build service

GR releases are also available from the [openSUSE Build service](https://software.opensuse.org//download.html?project=science%3Agr-framework&package=gr) for CentOS, Debian, Fedora openSUSE and Ubuntu. Obtain a packaged release [here](https://software.opensuse.org//download.html?project=science%3Agr-framework&package=gr).

GR will be installed in `/usr/gr`. Set one of the following environment variables so that GR.rb can find the library.

```sh
export GRDIR="/usr/gr" # Check the location with `dpkg -L gr`
```

```sh
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/gr/lib/pkgconfig"
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

If you are not familiar with Ruby gem development, please see
[I'm new to Ruby](https://github.com/red-data-tools/GR.rb/wiki/I%27m-new-to-Ruby)

```
Do you need commit rights to my repository?
Do you want to get admin rights and take over the project?
If so, please feel free to contact us.
```

I've seen a lot of OSS abandoned because no one has commit rights to the original repository anymore; the right to request commit rights for GR.rb is always open.

## Acknowledgements

We would like to thank Josef Heinen, the creator of [GR](https://github.com/sciapp/gr) and [GR.jl](https://github.com/jheinen/GR.jl), Florian Rhiem, the creator of [python-gr](https://github.com/sciapp/python-gr), and all [GR](https://github.com/sciapp/gr) developers.
