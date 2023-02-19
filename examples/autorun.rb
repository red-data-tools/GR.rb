#!/usr/bin/env ruby

require 'optparse'
require 'colorize'

skip_list = []
interval = 0.5
color = true
output_stderr = false
start_at = 0

opt_parser = OptionParser.new do |opts|
  opts.banner = "autrun.rb (Run examples automatically)\nUsage: #{__FILE__} [options]"

  opts.on('-h', '--help', 'Show this message') do
    puts opts
    exit
  end

  opts.on('-s', '--skip FNAMES', Array, 'Skip examples') do |skip|
    skip_list = skip
  end

  opts.on('--interval SEC', Integer, 'Interval between examples [0.5]') do |sec|
    interval = sec
  end

  opts.on('--[no-]color', 'Colorize output') do |v|
    color = v
  end

  opts.on('-e', '--output-error', 'Output stderr of examples') do |v|
    output_stderr = v
  end

  opts.on('--start-at N', Integer, 'Start at Nth example (0 based)') do |n|
    start_at = n
  end
end

opt_parser.parse!

Dir.chdir(__dir__)

examples_list = Dir.glob('*.rb') - [File.basename(__FILE__)] - skip_list
total = examples_list.size

examples_list[start_at..].each_with_index do |example, idx|
  print "(#{idx + 1}/#{total})\t#{example}".ljust(30)
  start_time = Time.now

  r, w = IO.pipe
  er, ew = IO.pipe
  pid = Process.spawn("ruby #{example}", in: r, out: ew, err: ew)
  th = Process.detach(pid)

  sleep(2)

  while th.alive?
    w.puts 'a'
    w.flush
    sleep(1)
    break unless th.alive?
  end

  status = th.value.success? ? '[success]' : '[failure]'
  if color
    status = status == '[success]' ? status.green : status.red
  end

  puts "\t#{(Time.now - start_time).round}s\t#{status}"

  if output_stderr
    ew.close
    msg = er.read
    unless msg.empty?
      msg = msg.yellow if color
      puts msg
    end
  end

  sleep(interval)
end
