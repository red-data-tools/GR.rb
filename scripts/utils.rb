require 'open-uri'
require 'colorize'

def extract_api(file, prefix)
  URI.open(file)
     .readlines
     .map(&:chomp)
     .map { _1.gsub(/#.*$/, '') }   # remove preprocessor directives
     .map { _1.gsub(%r{//.*}, '') } # remove single line comments
     .join
     .gsub(%r{/\*.*?\*/}m, '')      # remove multi line comments
     .tap { puts "count #{prefix} in #{file}: #{_1.scan(/#{prefix}/).size}".yellow }
     .gsub(/ +/, ' ')
     .each_line(';', chomp: true)
     .grep(/#{prefix}/)
     .map { _1.gsub(/^.*#{prefix} (.*)$/, '\1') }
     .tap { puts "#{file}: #{_1.size} lines".yellow }
     .join("\n")
     .chomp
     .+("\n")
end

def extract_ffi(file)
  File.read(file)
      .gsub(/' *\\\n *'/, '')
      .each_line("\n")
      .map(&:strip)
      .map { _1.gsub(/#.*$/, '') } # remove ruby comments
      .tap { puts "count try_extern in #{file}: #{_1.join.scan(/try_extern/).size}".yellow }
      .grep(/try_extern/)
      .map { _1.gsub(/^.*try_extern '([^']+)'.*$/, '\1') }
      .tap { puts "#{file}: #{_1.size} lines".yellow }
      .join("\n")
      .chomp
      .+("\n")
end
