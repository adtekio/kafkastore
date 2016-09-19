ENV['RAILS_ENV']     = 'test' # ensures that settings.environment == 'test'
ENV['RACK_ENV']      = 'test'
ENV['IP']            = 'www.example.com'
ENV['PORT']          = '9999'
ENV['TZ']            = 'UTC'
ENV['REDISTOGO_URL'] = "redis://localhost:6379/12"
ENV['KAFKA_HOST']    = "localhost"
ENV['COOKIE_SECRET'] = 'babeca7ea679fa45ca92566e83d801bc0b'

require "bundler/setup"
require 'rack/test'
require 'shoulda'
require 'rr'
# use binding.pry at any point of the tests to enter the pry shell
# and pock around the current object and state
#    https://github.com/pry/pry/wiki/Runtime-invocation
require 'pry'
require 'fakeweb'
require 'minitest/autorun'

require_relative '../application.rb'

raise "Not Using Test Environment" if settings.environment != 'test'

FakeWeb.register_uri(:post, /metrics-api.librato.com/, :status => 200)

class Minitest::Test
  include RR::Adapters::TestUnit

  def _pry
    binding.pry
  end

  def silence_is_golden
    old_stderr,old_stdout,stdout,stderr =
      $stderr, $stdout, StringIO.new, StringIO.new

    $stdout = stdout
    $stderr = stderr
    result = yield
    [result, stdout.string, stderr.string]
  ensure
    $stderr, $stdout = old_stderr, old_stdout
  end

  def assert_redirect_to(path, msg = nil)
    assert(last_response.redirect?,
           "Request was not redirect" + (msg ? " (#{msg})" : ""))
    assert_equal('http://example.org/%s' % path,
                 last_response.headers["Location"],
                 "Redirect location didn't match"+ (msg ? " (#{msg})" : ""))
  end

  def assert_click_params(params, unchanged_cl_data, msg = nil)
    unchanged_cl_data.each do |key, value|
      assert_equal(value, params[key.to_s].first, "Mismatch: #{key}")
    end
  end

  def replace_in_env(changes)
    original_values = Hash[changes.map { |k,_| [k,ENV[k] ]}]
    changes.each { |k,v| ENV[k] = v }
    yield
  ensure
    original_values.each { |key,value| ENV[key] = value }
  end

  def add_to_env(changes)
    changes.each { |k,v| ENV[k] = v }
    yield
  ensure
    changes.keys.each { |key| ENV.delete(key) }
  end
end
