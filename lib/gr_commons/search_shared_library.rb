module GRCommons
  module SearchSharedLibrary
    def search_shared_library(gr_lib_name)
      if Object.const_defined?(:RubyInstaller)
        ENV['GRDIR'] ||= [
          RubyInstaller::Runtime.msys2_installation.msys_path,
          RubyInstaller::Runtime.msys2_installation.mingwarch
        ].join(File::ALT_SEPARATOR)
        recursive_search(gr_lib_name, ENV['GRDIR']).tap do |path|
          RubyInstaller::Runtime.add_dll_directory(File.dirname(path))
        end
      else
        unless ENV['GRDIR']
          warn 'Please set environment variable GRDIR'
          exit 1
        end
        recursive_search(gr_lib_name, ENV['GRDIR'])
      end
    end

    def recursive_search(name, base_dir)
      Dir.chdir(base_dir) do
        if path = Dir["**/#{name}"].first
          File.expand_path(path)
        else
          raise StandardError '#{name} not found in #{base_dir}'
        end
      end
    end
  end
end
