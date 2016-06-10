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
    should "prevent access"
    should "allow access"
  end
end
