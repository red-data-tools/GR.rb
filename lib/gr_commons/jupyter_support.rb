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
          data = File.read("#{ENV['GKS_FILEPATH']}.svg")
          IRuby.display(data, mime: 'image/svg+xml') if display
        when 'png', '322', '140'
          data = File.read("#{ENV['GKS_FILEPATH']}.png")
          IRuby.display(data, mime: 'image/png') if display
        when 'jpg', '321', '144'
          data = File.read("#{ENV['GKS_FILEPATH']}.jpg")
          IRuby.display(data, mime: 'image/jpeg') if display
        when 'gif', '130'
          data = File.read("#{ENV['GKS_FILEPATH']}.gif")
          IRuby.display(data, mime: 'image/gif') if display
        when 'webm', 'ogg', 'mp4', 'mov'
          require 'base64'
          mimespec = if type == 'mov'
                       'movie/quicktime'
                     else
                       "video/#{type}"
                     end
          data = File.binread("#{ENV['GKS_FILEPATH']}.#{type}")
          if display
            IRuby.display(
              "<video autoplay controls><source type=\"#{mimespec}\" " \
              "src=\"data:#{mimespec};base64,#{Base64.encode64(data)}\">" \
              '</video>',
              mime: 'text/html'
            )
          end
        end
        data unless display
      end
    end
  end
end
