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
  # ENV['TZ'] = 'Europe/Ljubljana'
  Time.at(time.to_i).iso8601 # This is clearly insane, but works
end

def test
  ['@1210598719 +0000', '@1210624976 +0000', '@1210628554 +0000', '1307524564 +0000'].each do |date|
    time = parse_date(date)
    puts "#{date}: #{time.to_s}"
  end
end

parse_zonefile(ARGV[2]) if ARGV[2]
$timezones = { } unless ARGV[2]
# Last three commits before and including BachoTeX
# Rewrite bf8006f20cb304ff4380b6df203e444c71ce2968 (1/3)GIT_COMMITTER_DATE=@1460998208 +0100 GIT_COMMITTER_NAME=Arthur Reutenauer, localdate=2016-05-01T00:07:28+02:00
# Rewrite 2ead57dbb6cb1ad73e4de1cd7c7736039e8f9bca (2/3)GIT_COMMITTER_DATE=@1461073770 +0100 GIT_COMMITTER_NAME=Arthur Reutenauer, localdate=2016-05-01T00:07:28+02:00
# Rewrite 7ca338ed98b0c37a4dcb5a9884ac52276a584fcf (3/3)GIT_COMMITTER_DATE=@1462054048 +0200 GIT_COMMITTER_NAME=Mojca Miklavec, localdate=2016-05-01T00:07:28+02:00
# puts '2016-05-01T00:07:28+02:00'

puts parse_date(ARGV.first, ARGV[1])
