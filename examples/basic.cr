require "redis"
require "../src/ratelimit"

# make a new rate limit instace, passing in a redis connection
r = Ratelimit.new(Redis.new)

# limit request over this interval, in milliseconds
interval = 100

# allow max of this many requests in the interval
limit = 10

# loop until we go over the limit
until r.over_limit?("test", limit, interval)
  puts "Doing request"
  r.add("test", interval)
end

puts "Hit limit : #{r.used("test")}"