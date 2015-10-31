require "./spec_helper"
require "redis"
require "secure_random"

describe Ratelimit do
  interval_ms = 50
  limit = 1
  subject = Ratelimit.new(Redis.new)

  describe "#over_limit?" do
    key = SecureRandom.uuid

    it "returns false when never used before" do
      key = SecureRandom.uuid

      subject.over_limit?(key, limit, interval_ms).should be_falsey
    end

    it "returns false when under limit" do
      key = SecureRandom.uuid

      subject.add(key, interval_ms)
      subject.over_limit?(key, limit, interval_ms).should be_falsey
    end

    it "returns true when over limit" do
      key = SecureRandom.uuid

      subject.add(key, interval_ms)
      subject.add(key, interval_ms)
      subject.over_limit?(key, limit, interval_ms).should be_truthy
    end

    it "returns false after the interval is up" do
      key = SecureRandom.uuid

      subject.add(key, interval_ms)
      subject.add(key, interval_ms)
      subject.over_limit?(key, limit, interval_ms).should be_truthy
      
      sleep 0.05.seconds
      subject.over_limit?(key, limit, interval_ms).should be_falsey
    end
  end
  
  describe "#used" do
    it "returns the number of requests used" do
      key = SecureRandom.uuid

      subject.used(key).should eq(0)
      subject.add(key, interval_ms)
      subject.used(key).should eq(1)
    end
  end
  
  describe "#add" do
    it "adds items" do
      key = SecureRandom.uuid
      subject.used(key).should eq(0)
      subject.add(key, interval_ms)
      subject.add(key, interval_ms)
      subject.used(key).should eq(2)
    end

    it "expires the key in redis after the interval" do
      key = SecureRandom.uuid
      
      subject.used(key).should eq(0)
      subject.add(key, 100)
      subject.used(key).should eq(1)
      sleep 0.11.seconds
      subject.used(key).should eq(0)
    end
  end
  
  describe "#trim" do
    it "removes things older than the interval" do
      key = SecureRandom.uuid

      # add something with a long expire, then check it's there
      subject.add(key, interval_ms)
      subject.used(key).should eq(1)

      # trim with a short interval
      subject.trim(key, 0)

      # should be zero
      subject.used(key).should eq(0)
    end
  end
end
