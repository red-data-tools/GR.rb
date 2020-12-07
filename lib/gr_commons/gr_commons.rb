# frozen_string_literal: true

# Module with common code for GR, GR3.
module GRCommons
end

# Change the default encoding to UTF-8.
ENV['GKS_ENCODING'] ||= 'utf8'

require_relative 'gr_lib'
require_relative 'try_extern'
require_relative 'define_methods'
require_relative 'gr_common_utils'
require_relative 'jupyter_support'
require_relative 'version'
