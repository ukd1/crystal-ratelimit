require "secure_random"

class Ratelimit
  VERSION = "0.1.0".freeze

  def initialize(redis)
    @redis = redis
  end

  def over_limit?(key, limit, interval_ms)
    trim(key, interval_ms)
    used(key) > limit
  end

  def used(key)
    @redis.zcard(key)
  end

  def add(key, interval_ms)
    @redis.zadd(key, t_ms, SecureRandom.uuid)
    @redis.pexpire(key, interval_ms)
  end

  def trim(key, interval_ms)
    @redis.zremrangebyscore(key, "-inf", t_ms - interval_ms)
  end

  def t_ms
    Time.now.epoch_ms
  end
end
