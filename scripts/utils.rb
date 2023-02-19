require 'open-uri'
require 'colorize'

def extract_api(file, prefix)
  contents = ''
  URI.open(file) do |f|
    contents = \
      f.each_line
       .map(&:chomp)
       .map { _1.gsub(/#.*$/, '') }   # remove preprocessor directives
       .map { _1.gsub(/\/\/.*/, '') } # remove single line comments
       .join
       .gsub(/\/\*.*?\*\//m, '')      # remove multi line comments
       .tap{ puts "count #{prefix} in #{file}: #{_1.scan(/#{prefix}/).size}".yellow }
       .gsub(/ +/, ' ')
       .each_line(';', chomp: true)
       .grep(/#{prefix}/)
       .map { _1.gsub(/^.*#{prefix} (.*)$/, '\1') }
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
       .map{ _1.gsub(/#.*$/, '')} # remove ruby comments
       .tap { puts "count try_extern in #{file}: #{_1.join.scan(/try_extern/).size}".yellow }
       .grep(/try_extern/)
       .map { _1.gsub(/^.*try_extern '([^']+)'.*$/, '\1') }
       .tap { puts "#{file}: #{_1.size} lines".yellow }
       .join("\n")
  end
  contents
end
