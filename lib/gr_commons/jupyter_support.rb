# frozen_string_literal: true

module GRCommons
  # Jupyter Notebook and Jpyter Lab.
  module JupyterSupport
    if defined? IRuby && IRuby.respond_to?(:display)
      def self.extended(_obj)
        require 'tmpdir'
        ENV['GKSwstype'] = 'svg'
        # May be extended to both GR3 and GR
        ENV['GKS_FILEPATH'] = Dir::Tmpname.create('plot-') {}
      end

      def show
        emergencyclosegks
        sleep 0.5
        case ENV['GKSwstype']
        when 'svg'
          data = File.read(ENV['GKS_FILEPATH'] + '.svg')
          IRuby.display(data, mime: 'image/svg+xml')
        when 'mov', 'mp4', 'webm'
          require 'base64'
          data = File.binread(ENV['GKS_FILEPATH'] + '.' + ENV['GKSwstype'])
          IRuby.display("<video controls autoplay type=\"video/mp4\" src=\"data:video/mp4;base64,#{Base64.encode64(data)}\">", mime: 'text/html')
        end
        nil
      end
    end
  end
end
