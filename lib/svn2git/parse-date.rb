#!/usr/bin/env ruby
require 'time'

def parse_zonefile(filename)
  $timezones = { }
  File.read(filename).each_line do |line|
    if line =~ /^([^=]+)=([^=]+)$/
      author = $1.strip
      timezone = $2.strip
      $timezones[author] = timezone
    end
  end
end

def parse_date(date, author)
  matches = /^@(?<timestamp>\d+) \+(?<timezone>\d{4})$/.match(date)
  if matches
    timestamp = matches['timestamp'].to_i
    time = Time.at(timestamp)
  else
      matches = /^(?<timestamp>\d+) \+(?<timezone>\d{4})$/.match(date)
    if matches
      timestamp = matches['timestamp'].to_i
      time = Time.at(timestamp)
    else
      matches = /^@(?<timestamp>\d+)$/.match(date)
      if matches
        timestamp = matches['timestamp'].to_i
        time = Time.at(timestamp)
      else
        raise StandardError.new("Couldn’t parse committer date: #{date.to_s}")
      end
    end
  end

  timezone = $timezones[author]
  timezone = 'Europe/Paris' if author == 'Arthur Reutenauer' && time.year < 2011
  ENV['TZ'] = timezone
  time.iso8601
end

def test
  ['@1210598719 +0000', '@1210624976 +0000', '@1210628554 +0000', '1307524564 +0000'].each do |date|
    time = parse_date(date)
    puts "#{date}: #{time.to_s}"
  end
end

parse_zonefile(ARGV[2]) if ARGV[2]
$timezones = { } unless ARGV[2]
puts parse_date(ARGV.first, ARGV[1])
