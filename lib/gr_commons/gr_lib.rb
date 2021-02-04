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
  module GRLib
    class << self
      # Search the shared library.
      # @note This method does not detect the Operating System.
      #
      # @param lib_names [Array] The actual file name of the shared library.
      # @param pkg_name [String] The package name to be used when searching with pkg-configg
      def search(lib_names, pkg_name)
        def lib_names.map_find(&block)
          lazy.map(&block).find { |path| path }
        end
        # Windows + RubyInstaller
        if Object.const_defined?(:RubyInstaller)
          dir = ENV['GRDIR'] || [
            RubyInstaller::Runtime.msys2_installation.msys_path,
            RubyInstaller::Runtime.msys2_installation.mingwarch
          ].join(File::ALT_SEPARATOR)
          lib_names.lazy.map do |lib_name|
            recursive_search(lib_name, dir)
          end.find { |i| i }.tap do |path|
            RubyInstaller::Runtime.add_dll_directory(File.dirname(path)) if path
          end
        # ENV['GRDIR'] (Linux, Mac, Windows)
        elsif ENV['GRDIR']
          # Search for XXX.dylib and then XXX.so on macOS
          lib_names.map_find do |lib_name|
            recursive_search(lib_name, ENV['GRDIR'])
          end || lib_names.map_find do |lib_name|
            pkg_config_search(lib_name, pkg_name)
          end
        else
          lib_names.map_find do |lib_name|
            pkg_config_search(lib_name, pkg_name)
          end
        end
      end

      # Recursive file search in directories
      # @param name [String] File to search for
      # @param base_dir [String] Directory to search
      # @retrun path [String, NilClass] Returns the first path found.
      #                                 If not found, nil is returned.
      def recursive_search(name, base_dir)
        Dir.chdir(base_dir) do
          paths = Dir["**/#{name}"].sort
          warn "More than one file found: #{paths}" if paths.size > 1
          path = paths.first
          File.expand_path(path) if path
        end
      end

      # Use pkg-config to search for shared libraries
      def pkg_config_search(lib_name, pkg_name)
        PKGConfig.variable(pkg_name, 'sopath')
      rescue PackageConfig::NotFoundError => e
        warn "#{e.message} Cannot find #{lib_name}. "
      end
    end
  end
end
