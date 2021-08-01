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
      # Check if using RubyInstaller or not.
      def ruby_installer?
        Object.const_defined?(:RubyInstaller)
      end

      # Return the directory path from the GRDIR environment variable.
      def get_grdir_from_env(lib_names)
        return nil unless ENV['GRDIR']
        return ENV['GRDIR'] if Dir.exist?(ENV['GRDIR'])

        warn "#{lib_names} : Dir GRDIR=#{ENV['GRDIR']} not found." # return nil
      end

      # Search the shared library.
      # @note This method does not detect the Operating System.
      #
      # @param lib_names [Array] The actual file name of the shared library.
      # @param pkg_name [String] The package name to be used when searching with pkg-configg
      def search(lib_names, pkg_name)
        # FIXME: There may be a better way to do it...
        def lib_names.map_find(&block)
          lazy.map(&block).find { |path| path }
        end

        # ENV['GRDIR']
        # Verify that the directory exists.
        grdir = get_grdir_from_env(lib_names)

        # Windows + RubyInstaller
        if ruby_installer?
          grdir ||= File.join(RubyInstaller::Runtime.msys2_installation.msys_path,
                              RubyInstaller::Runtime.msys2_installation.mingwarch)
        end

        # Search grdir
        if grdir
          lib_path = lib_names.map_find do |lib_name|
            recursive_search(lib_name, grdir)
          end
        end

        # Search with pkg-config
        lib_path ||= lib_names.map_find do |lib_name|
          pkg_config_search(lib_name, pkg_name)
        end

        # Windows + RubyInstaller
        if ruby_installer?
          RubyInstaller::Runtime.add_dll_directory(File.dirname(lib_path))
          # FIXME: Where should I write this code?
          ENV['GKS_FONTPATH'] ||= grdir
        end

        lib_path
      end

      # Recursive file search in directories
      # @param name [String] File to search for
      # @param base_dir [String] Directory to search
      # @return path [String, NilClass] Returns the first path found.
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
