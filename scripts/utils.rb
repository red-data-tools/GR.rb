# frozen_string_literal: true

require 'open-uri'
require 'colorize'

def strip_cpp_sections(source)
  cpp_depth = 0

  source.each_line.filter_map do |line|
    if line.match?(/^\s*#\s*ifdef\s+__cplusplus\b/)
      cpp_depth += 1
      next
    end

    if cpp_depth.positive?
      cpp_depth += 1 if line.match?(/^\s*#\s*(?:if|ifdef|ifndef)\b/)
      cpp_depth -= 1 if line.match?(/^\s*#\s*endif\b/)
      next
    end

    line
  end.join
end

def extract_api(file, prefix, c_only: false)
  source = URI.open(file).read
  source = strip_cpp_sections(source) if c_only

  api = source
        .lines
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

  "#{api.chomp}\n"
end

def extract_ffi(file)
  ffi = File.read(file)
            .gsub(/' *\\\n *'/, '')
            .each_line("\n")
            .map(&:strip)
            .map { _1.gsub(/#.*$/, '') } # remove ruby comments
            .tap { puts "count try_extern in #{file}: #{_1.join.scan(/try_extern/).size}".yellow }
            .grep(/try_extern/)
            .map { _1.gsub(/^.*try_extern '([^']+)'.*$/, '\1') }
            .tap { puts "#{file}: #{_1.size} lines".yellow }
            .join("\n")

  "#{ffi.chomp}\n"
end
