# frozen_string_literal: true

require 'gr/plot'

Dir.chdir(__dir__)
FileUtils.mkdir_p 'savefig'

x = [1, 2, 3, 4, 5]
y = [1, 8, 27, 64, 125]

GR.plot(x, y)
GR.savefig('savefig/image.pdf')
GR.savefig('savefig/image.ps')
GR.savefig('savefig/image.gif')
GR.savefig('savefig/image.bmp')
GR.savefig('savefig/image.jpg')
GR.savefig('savefig/image.png')
GR.savefig('savefig/image.tiff')
GR.savefig('savefig/image.svg')
