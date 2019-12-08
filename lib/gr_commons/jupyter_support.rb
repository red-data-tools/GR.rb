# frozen_string_literal: true

module GRCommons
  # Jupyter Notebook and Jpyter Lab.
  module JupyterSupport
    if defined?(IRuby) && IRuby.respond_to?(:display)

      # Sets the environment variable when the module is extended.
      def self.extended(_obj)
        require 'tmpdir'
        ENV['GKSwstype'] = 'svg'
        ENV['GKS_FILEPATH'] = Dir::Tmpname.create('plot-') {}
      end

      # Display your plot in Jupyter Notebook / Lab
      def show(display = true)
        emergencyclosegks
        sleep 0.5
        type = ENV['GKSwstype']
        case type
        when 'svg'
          data = File.read(ENV['GKS_FILEPATH'] + '.svg')
          IRuby.display(data, mime: 'image/svg+xml') if display
        when 'webm', 'ogg', 'mp4', 'mov'
          require 'base64'
          data = File.binread(ENV['GKS_FILEPATH'] + '.' + type)
          if display
            IRuby.display(
              "<video controls autoplay type=\"video/#{type}\" " \
              "src=\"data:video/#{type};base64,#{Base64.encode64(data)}\">",
              mime: 'text/html'
            )
          end
        end
        data unless display
      end
    end
  end
end
