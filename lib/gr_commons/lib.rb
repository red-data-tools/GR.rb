# frozen_string_literal: true

require 'pkg-config'

module GRCommons
  # This module helps GR, GR and GRM to search the shared library.
  #
  # The order of priority:
  # 1. RubyInstaller ( for Windows only )
  # 2. Environment variable GRDIR
  # 3. pkg-config : https://github.com/ruby-gnome/pkg-config
  # The following packages (should) support pkg-config.
  # - Linux
  #   - Red Data Tools https://github.com/red-data-tools/packages.red-data-tools.org
  #     - libgr-dev
  #     - libgr3-dev
  #     - libgrm-dev
  # - Mac
  #   - Homebrew https://github.com/Homebrew/homebrew-core
  #     - libgr
  # - Windows
  #   - MinGW https://github.com/msys2/MINGW-packages
  #     - mingw-w64-gr
  module Lib
    # Search the shared library.
    # @note This method does not detect the Operating System.
    #
    # @param gr_lib_name [String] The actual file name of the shared library.
    # @param pkg_name [String] The package name to be used when searching with pkg-configg
    def self.search(gr_lib_name, pkg_name)
      # Windows + RubyInstaller
      if Object.const_defined?(:RubyInstaller)
        ENV['GRDIR'] ||= [
          RubyInstaller::Runtime.msys2_installation.msys_path,
          RubyInstaller::Runtime.msys2_installation.mingwarch
        ].join(File::ALT_SEPARATOR)
        recursive_search(gr_lib_name, ENV['GRDIR']).tap do |path|
          RubyInstaller::Runtime.add_dll_directory(File.dirname(path))
        end
      # ENV['GRDIR'] (Linux, Mac, Windows)
      elsif ENV['GRDIR']
        begin
          recursive_search(gr_lib_name, ENV['GRDIR'])
        rescue StandardError => e
          warn "\nWhile searching for #{gr_lib_name} in the directory specified " \
               "in the GRDIR environment variable, ENV['GRDIR']=#{ENV['GRDIR']}, " \
               "the following error occurred : #{e.message}"
          pkg_config_search(gr_lib_name, pkg_name)
        end
      else
        pkg_config_search(gr_lib_name, pkg_name)
      end
    end

    def self.recursive_search(name, base_dir)
      Dir.chdir(base_dir) do
        path = Dir["**/#{name}"].first # FIXME
        if path
          File.expand_path(path)
        else
          raise "#{name} not found in #{base_dir}"
        end
      end
    end

    def self.pkg_config_search(gr_lib_name, pkg_name)
      PKGConfig.variable(pkg_name, 'sopath')
    rescue PackageConfig::NotFoundError => e
      raise "#{e.message} Cannot find #{gr_lib_name}. " \
            "Please Make sure that GR is installed and the environment ” \
            ”variable GRDIR is set correctly."
    end
  end
end
