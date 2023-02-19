require 'open-uri'
require 'colorize'

def extract_api(file, prefix)
  contents = ''
  URI.open(file) do |f|
    contents = \
      f.each_line
       .map(&:chomp)
       .map { |l| l.gsub(/#.*$/, '') }
       .join
       .gsub(/ +/, ' ')
       .each_line(';', chomp: true)
       .grep(/^#{prefix}/)
       .map { _1.delete_prefix("#{prefix} ") }
       .tap { puts "#{file}: #{_1.size} lines".yellow }
       .join("\n")
  end
  contents
end

def extract_ffi(file)
  contents = ''
  File.open(file) do |f|
    contents = \
      f.read
       .gsub(/' *\\\n *'/, '')
       .each_line("\n")
       .map(&:strip)
       .grep(/try_extern/)
       .map { _1.gsub(/^.*try_extern '([^']+)'.*$/, '\1') }
       .tap { puts "#{file}: #{_1.size} lines".yellow }
       .join("\n")
  end
  contents
end