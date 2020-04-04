# frozen_string_literal: true

require 'gr/plot'

%i[barplot stem step plot].each_with_index do |t, i|
  h = GR.subplot(2, 2, i + 1)
  GR.send t, [*1..10], [*1..10].shuffle, h.merge(title: "subplot #{i}")
end
gets
