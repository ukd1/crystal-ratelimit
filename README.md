# ratelimit

Simple rate limiting class, backed by Redis sorted sets that use a minimal amounts of keys.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  ratelimit:
    github: ukd1/ratelimit
```

## Usage

```crystal
require "redis"
require "ratelimit"

redis = Redis.new()

# make a new rate limit instace, passing in a redis connection
r = Ratelimit.new(redis)

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
```

## Development

You'll need a working Redis database.

## Contributing

1. Fork it ( https://github.com/[your-github-name]/ratelimit/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[ukd1]](https://github.com/ukd1) Russell Smith - creator, maintainer
