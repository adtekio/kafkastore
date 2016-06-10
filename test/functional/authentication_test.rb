# encoding: UTF-8
require_relative '../test_helper'

class AuthenticaionTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  def setup
  end

  context "authentication" do
    should "prevent access" do
      ["/sidekiq"
       ].each do |path|
        get path
        assert_redirect_to("auth/google_auth2", "Failed for #{path}")
      end
    end

    should "allow access" do
      ["/pingdom"].
        each do |path|
        get path
        assert last_response.ok?, "Failed for #{path}"
      end
    end
  end
end
